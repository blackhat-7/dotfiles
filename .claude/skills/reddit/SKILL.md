---
name: reddit
description: Search and retrieve content from Reddit. Get posts, comments, subreddit info, and user profiles via the public JSON API. Use when user mentions Reddit, a subreddit, or r/ links.
---

# Reddit Skill

**IMPORTANT**: All commands run from `~/.claude/skills/reddit` directory. Use workdir parameter.

## Commands

**Search posts**
```bash
./reddit.py search "query" --subreddit NAME --sort top --time week --limit 20
```

**Get subreddit posts**
```bash
./reddit.py posts SUBREDDIT --sort hot --limit 20
```

**Get subreddit info**
```bash
./reddit.py subreddit NAME
```

**Get post details**
```bash
./reddit.py post POST_ID --comments 50
```

**Get user profile**
```bash
./reddit.py user USERNAME --posts 10
```

## Sort Options
- hot, new, top, rising, controversial
- Time filters (for top/controversial): hour, day, week, month, year, all
