// macOS has no pam_exec, so this PAM module runs /etc/sudo-approve the way the Linux PAM lines
// do (see install and README.md). Used as `auth sufficient` in /etc/pam.d/sudo_local:
// not an agent gives PAM_IGNORE, so sudo asks for the password; for an agent the phone decides.
// It makes no PAM calls, so it needs no libpam: Nix could only link its own copy, not the
// system one that sudo uses.
#include <crt_externs.h>
#include <errno.h>
#include <fcntl.h>
#include <pwd.h>
#include <security/pam_modules.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

static void put(char **env, int *n, const char *name, const char *value) {
  if (value && asprintf(&env[*n], "%s=%s", name, value) >= 0) ++*n;
}

// Runs the helper as root (like pam_exec's seteuid) with what pam_exec would give it, plus
// sudo's agent markers, as macOS has no /proc. Its stdout, where it explains a failure, goes
// to the caller's stderr. Returns its exit code, or -1.
static int run(char *const argv[]) {
  char *env[6];
  int n = 0;
  put(env, &n, "PAM_TYPE", "auth");
  // Sudo's real user is the caller, and sudo's terminal is its controlling one, if any.
  struct passwd *pw = getpwuid(getuid());
  put(env, &n, "PAM_RUSER", pw ? pw->pw_name : NULL);
  int tty = open("/dev/tty", O_RDONLY);
  if (tty >= 0) {
    close(tty);
    put(env, &n, "PAM_TTY", "/dev/tty");
  }
  put(env, &n, "AI_AGENT", getenv("AI_AGENT"));
  put(env, &n, "GEMINI_CLI", getenv("GEMINI_CLI"));
  env[n] = NULL;

  // waitpid needs the default SIGCHLD action, as in pam_exec.
  struct sigaction dfl = {.sa_handler = SIG_DFL}, old;
  sigaction(SIGCHLD, &dfl, &old);
  int status = -1;
  pid_t pid = fork();
  if (pid == 0) {
    int devnull = open("/dev/null", O_RDONLY);
    if (devnull < 0 || dup2(devnull, 0) < 0 || dup2(2, 1) < 0 || setuid(geteuid()) < 0) _exit(127);
    execve("/etc/sudo-approve", argv, env);
    _exit(127);
  }
  if (pid > 0) {
    while (waitpid(pid, &status, 0) < 0 && errno == EINTR) {}
  }
  sigaction(SIGCHLD, &old, NULL);
  for (int i = 0; i < n; i++) free(env[i]);
  return status >= 0 && WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  if (run((char *[]){"sudo-approve", "check", NULL}) != 0) return PAM_IGNORE;
  // The phone shows sudo's own command line.
  int sudo_argc = *_NSGetArgc();
  char **sudo_argv = *_NSGetArgv();
  char **args = calloc(sudo_argc + 2, sizeof *args);
  if (!args) return PAM_AUTH_ERR;
  args[0] = "sudo-approve";
  for (int i = 0; i < sudo_argc; i++) args[i + 1] = sudo_argv[i];
  int rc = run(args);
  free(args);
  return rc == 0 ? PAM_SUCCESS : PAM_AUTH_ERR;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  return PAM_IGNORE;
}
