// The Touch ID box of sudo-approve-mac (see README.md): touchid-prompt SECONDS TEXT.
// It runs as root in the logged-in user's session. Nix builds it as "sudo" because the box
// names the program asking: "sudo is trying to TEXT".
// Exit 0: approved with Touch ID, an Apple Watch or the Mac password. 1: Cancel.
// 2: anything else: no answer in SECONDS, no box possible, or SIGTERM, which closes the box.
#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#include <signal.h>

int main(int argc, char *argv[]) {
  if (argc != 3) return 2;
  LAContext *context = [LAContext new];
  signal(SIGTERM, SIG_IGN);
  dispatch_source_t term =
      dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_global_queue(0, 0));
  dispatch_source_set_event_handler(term, ^{ [context invalidate]; });
  dispatch_resume(term);

  __block int rc = 2;
  dispatch_semaphore_t done = dispatch_semaphore_create(0);
  // 0x3f0 is LocalAuthentication's private "device owner, ignoring user ID" policy: it asks the
  // logged-in user although we run as root. The public policies would ask root, who has no Touch ID.
  [context evaluatePolicy:(LAPolicy)0x3f0
          localizedReason:@(argv[2])
                    reply:^(BOOL ok, NSError *error) {
                      rc = ok ? 0 : error.code == LAErrorUserCancel ? 1 : 2;
                      dispatch_semaphore_signal(done);
                    }];
  if (dispatch_semaphore_wait(done, dispatch_time(DISPATCH_TIME_NOW, atoll(argv[1]) * NSEC_PER_SEC))) {
    [context invalidate];
  }
  return rc;
}
