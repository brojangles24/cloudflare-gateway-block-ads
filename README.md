Cloudflare Gateway Block Ads (1Hosts Lite Edition)

A GitHub Actions workflow and Bash script to automatically create and update Cloudflare Zero Trust Gateway DNS ad-blocking lists and policy using the 1Hosts Lite
 blocklist.

The script downloads the latest domains.wildcards list from 1Hosts Lite, removes comments and blank lines, splits it into multiple smaller chunks (to fit Cloudflare’s 1,000-domain per-list limit), uploads them as Cloudflare Gateway DNS Lists, and creates a DNS policy that blocks all domains in those lists.

It only updates Cloudflare when the 1Hosts list changes — preventing unnecessary API calls.

🚀 How It Works

Downloads the 1Hosts Lite blocklist
Uses https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/domains.wildcards.

Filters and chunks domains
Removes comments (#) and blank lines, then splits into lists of up to 1,000 domains (Cloudflare’s limit).
Supports up to 100 lists (100k domains total).

Syncs with Cloudflare Gateway

Updates existing lists via the Lists API

Creates new ones if needed

Deletes extra ones if there are too many

Updates or creates a single DNS block policy matching your prefix (e.g., Block ads)

Skips updates when the list hasn’t changed since the previous run.

⚙️ Setup
1. Cloudflare Setup

You’ll need:

A Cloudflare Zero Trust account (Free plan works) → Sign up here

A Cloudflare API Token with the Account.Zero Trust permission
→ Create one at https://dash.cloudflare.com/profile/api-tokens

Your Cloudflare Account ID
→ Found on your Account Home page URL (a 32-character string)

Optionally, if you’re using zone-level lists, also grab your Zone ID from the domain’s Overview tab.

2. GitHub Setup

Fork this repository (click the Fork button in the top right).

In your fork, go to Settings → Secrets and variables → Actions and add:

CF_API_TOKEN → your Cloudflare API token

CF_ACCOUNT_ID → your Cloudflare account ID

Enable GitHub Actions:

Go to Settings → Actions → General

Allow All actions and reusable workflows

Grant Read and write permissions
