# VibeCheck

Don't Get Hacked. Don't Go Blind.

Check the vibe of your AI-generated code. An intelligent analyzer that scans GitHub repositories for security vulnerabilities and monitoring gaps that AI coding assistants miss - before your users find them.

## Features

- 🔍 **Scans Your Code**: Paste your GitHub link and check every file ChatGPT or Claude generated for hidden problems
- 🚨 **Finds What AI Missed**: Security holes that let hackers in, missing error tracking that leaves you blind when crashes happen
- 💬 **Plain English Fixes**: No confusing tech jargon. Get copy-paste prompts that fix issues in minutes, not hours
- 🔗 **GitHub Integration**: Direct links to code locations on GitHub with line numbers
- 💾 **Analysis History**: Saves previous analysis results locally
- 🎨 **Modern UI**: Clean, dark-themed interface with gradient accents

## Live Demo

🌐 **Website**: https://vibe-checker.dev
🚀 **Web App**: https://app.vibe-checker.dev

## Setup

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- OpenAI API key
- GitHub Personal Access Token (optional, but recommended for higher rate limits)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Tell-Me-Mo/vibe-app-analyzer.git
cd vibe-app-analyzer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory:
```bash
cp .env.example .env
```

4. Add your API keys to `.env`:
```env
OPENAI_API_KEY=your_openai_api_key_here
GITHUB_TOKEN=your_github_token_here
```

### Running Locally

```bash
flutter run -d chrome
```

### Building for Production

```bash
flutter build web --release --wasm
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | Your OpenAI API key for GPT-4o-mini |
| `GITHUB_TOKEN` | No | GitHub Personal Access Token (increases rate limit from 60 to 5,000 req/hour) |

## How It Works

1. **Paste GitHub URL**: Enter your public GitHub repository URL or live app URL
2. **AI Scans Code**: App fetches repository code via GitHub API and sends to OpenAI GPT-4o-mini
3. **Get Results in 60 Seconds**: AI analyzes code and returns structured findings with exact file locations
4. **Review Issues**: Results displayed with severity levels, descriptions, and clickable GitHub links
5. **Copy-Paste Fixes**: Each issue includes a plain English Claude Code prompt to fix it
6. **Launch Confidently**: Know your code is safe before users find the problems

## Pricing

- **Free**: 10 credits on signup (no credit card required)
- **Starter**: $4.99 for 20 credits
- **Professional**: $9.99 for 50 credits (Popular)
- **Enterprise**: $39.99 for 300 credits

Each scan uses 5 credits • Checking fixes uses 1 credit • Credits never expire

## Security Notes

- **Never commit `.env` file** - It contains sensitive API keys
- API keys are loaded at runtime from `.env`
- For production, use environment variables or secure secret management
- `.env` is already added to `.gitignore`

## Technologies Used

- **Flutter Web** with WASM support for high performance
- **Riverpod** for state management
- **OpenAI GPT-4o-mini** for AI-powered code analysis
- **GitHub API** for repository access
- **Firebase Analytics** for usage tracking and insights
- **Supabase** for backend and database
- **Nginx** with SSL/TLS for production hosting
- **Let's Encrypt** for SSL certificates
- **Google Analytics** for website analytics

## Project Structure

```
├── lib/                    # Flutter application code
│   ├── features/          # Feature modules (analysis, history, etc.)
│   ├── providers/         # Riverpod state providers
│   └── services/          # API services (OpenAI, GitHub)
├── docs/                  # Marketing website
│   ├── index.html        # Main landing page
│   └── blog/             # Blog articles
└── web/                   # Flutter web build output
```

## SEO & Analytics

- **Sitemap**: https://vibe-checker.dev/sitemap.xml
- **Google Analytics**: Configured for website traffic tracking
- **Firebase Analytics**: Integrated in Flutter app for user behavior analysis

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

---

Made with ❤️ for vibe coders everywhere
🤖 Built with Claude Code
