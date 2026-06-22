# LinkedIn Content Creation Automation — Setup Guide

## What This Does

You fill out a simple form → Claude AI writes a LinkedIn post → it auto-publishes to your LinkedIn profile → you get a confirmation email.

**Flow:** Form → AI Generation (Claude) → LinkedIn API → Gmail notification

---

## Prerequisites

- [n8n](https://n8n.io) instance (cloud or self-hosted)
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com))
- LinkedIn account with API access
- Gmail account for notifications

---

## Step 1 — Import the Workflow

1. Open your n8n instance
2. Go to **Workflows → Import from file**
3. Upload `workflow.json` from this folder
4. The workflow will appear with all nodes connected

---

## Step 2 — Set Up Credentials

You need to configure 3 credentials in n8n (**Settings → Credentials → New**):

### A. Anthropic API
| Field | Value |
|---|---|
| Type | `Anthropic` |
| API Key | Your key from [console.anthropic.com](https://console.anthropic.com) |

### B. LinkedIn OAuth2
| Field | Value |
|---|---|
| Type | `LinkedIn OAuth2 API` |
| Client ID | From your [LinkedIn Developer App](https://www.linkedin.com/developers/apps) |
| Client Secret | From your LinkedIn Developer App |
| Scopes | `w_member_social`, `r_liteprofile` |

**LinkedIn App Setup:**
1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/apps) → Create App
2. Add product: **Share on LinkedIn**
3. Copy Client ID and Client Secret
4. Set OAuth 2.0 redirect URL to: `https://YOUR-N8N-URL/rest/oauth2-credential/callback`

### C. Gmail OAuth2
| Field | Value |
|---|---|
| Type | `Gmail OAuth2` |
| Client ID | From [Google Cloud Console](https://console.cloud.google.com) |
| Client Secret | From Google Cloud Console |

**Quick alternative:** Use n8n's built-in **Send Email** node with SMTP instead of Gmail OAuth2.

---

## Step 3 — Assign Credentials to Nodes

After creating credentials, open each node and select the correct credential:

| Node | Credential |
|---|---|
| Generate Post (Claude) | Anthropic API |
| Post to LinkedIn | LinkedIn OAuth2 |
| Send Success Email | Gmail OAuth2 |
| Send Failure Email | Gmail OAuth2 |

---

## Step 4 — Update the Failure Email Address

In the **Send Failure Email** node, change `your@email.com` to your actual email address.

---

## Step 5 — Activate & Test

1. Click **Activate** (toggle in top right) to make the workflow live
2. Open the **Form Trigger** node → copy the **Production URL**
3. Open that URL in your browser — you'll see the form
4. Fill it out and submit
5. Check your LinkedIn profile and inbox

---

## Form Fields

| Field | Description |
|---|---|
| **Topic** | What to write about (required) |
| **Tone** | Professional / Conversational / Inspirational / Educational / Storytelling |
| **Target Audience** | Who you're writing for (optional but improves quality) |
| **Key Points** | Notes or bullet points to include (optional) |
| **Include Hashtags** | Adds 3-5 relevant hashtags at the end |
| **Include Call to Action** | Adds an engaging question or prompt |

---

## Customizing the AI Prompt

The **Build Prompt** node contains the logic that builds the Claude prompt. Edit the `userPrompt` string in that Code node to:

- Change post length (currently 150-300 words)
- Add your personal writing style examples
- Force certain phrases or sign-offs
- Add industry-specific context

---

## Workflow Architecture

```
Form Trigger
    │
    ▼
Build Prompt (Code)
    │  Constructs system + user prompt from form inputs
    ▼
Generate Post (Claude AI)
    │  claude-sonnet-4-6, temp 0.8, max 1024 tokens
    ▼
Format & Validate Post (Code)
    │  Extracts text, enforces 3000-char LinkedIn limit
    ▼
Post to LinkedIn
    │  Publishes as PUBLIC post to your profile
    ▼
Build Summary (Code)
    │
    ▼
Post Successful? (IF)
    ├── YES → Send Success Email (with post text + LinkedIn link)
    └── NO  → Send Failure Email
```

---

## Troubleshooting

**LinkedIn post not appearing**
- Verify OAuth scopes include `w_member_social`
- Re-authenticate the LinkedIn credential in n8n
- Check n8n execution logs for the exact API error

**Claude not generating content**
- Confirm the Anthropic API key is valid and has credits
- Check the model ID in the node (`claude-sonnet-4-6`)

**Email not sending**
- For Gmail: ensure the OAuth app has Gmail send scope
- Alternative: swap to SMTP using the `Send Email` node

**Form not loading**
- The workflow must be **Active** (not just saved) for the form URL to work
