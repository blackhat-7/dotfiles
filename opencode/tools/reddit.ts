import { tool } from "@opencode-ai/plugin"

async function run(args: Record<string, unknown>) {
  const process = Bun.spawn(["ai-tools-cli", "reddit", JSON.stringify(args)], {
    stdout: "pipe",
    stderr: "pipe",
  })

  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(process.stdout).text(),
    new Response(process.stderr).text(),
    process.exited,
  ])

  if (exitCode !== 0) {
    throw new Error(stderr.trim() || "ai-tools-cli failed for reddit")
  }

  return stdout.trim()
}

export default tool({
  description: "Read Reddit.",
  args: {
    op: tool.schema.enum(["search", "posts", "subreddit", "post", "user"]),
    query: tool.schema.string().optional(),
    subreddit: tool.schema.string().optional(),
    sort: tool.schema
      .enum(["relevance", "hot", "top", "new", "comments", "rising", "controversial"])
      .optional(),
    time: tool.schema.enum(["hour", "day", "week", "month", "year", "all"]).optional(),
    limit: tool.schema.number().int().min(1).max(100).optional(),
    post_id: tool.schema.string().optional(),
    comments: tool.schema.number().int().min(1).max(100).optional(),
    username: tool.schema.string().optional(),
    posts: tool.schema.number().int().min(1).max(100).optional(),
  },
  async execute(args) {
    return run(args)
  },
})
