#!/usr/bin/env python3
"""Reddit API wrapper - single entry point"""

import sys
import os

# Add scripts dir to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "scripts"))

if len(sys.argv) < 2:
    print("Usage: reddit.py <command> [args]")
    print("Commands: search, posts, subreddit, post, user")
    sys.exit(1)

cmd = sys.argv[1]
sys.argv = [sys.argv[0]] + sys.argv[2:]  # Remove command from args

if cmd == "search":
    from search_posts import main
elif cmd == "posts":
    from get_posts import main
elif cmd == "subreddit":
    from get_subreddit import main
elif cmd == "post":
    from get_post import main
elif cmd == "user":
    from get_user import main
else:
    print(f"Unknown command: {cmd}")
    sys.exit(1)

main()
