# VibeCheck

Check the vibe of your AI-generated code. An intelligent analyzer that scans GitHub repositories for security vulnerabilities and monitoring opportunities in AI-generated applications.

## Features

- 🔒 **Security Analysis**: Detects vulnerabilities in AI-generated code (hardcoded secrets, SQL injection, XSS, etc.)
- 📊 **Monitoring Analysis**: Identifies missing business metrics and observability opportunities
- 🤖 **AI-Powered**: Uses OpenAI GPT-4o-mini for intelligent code analysis
- 🔗 **GitHub Integration**: Direct links to code locations on GitHub with line numbers
- 💾 **Analysis History**: Saves previous analysis results locally
- 🎨 **Modern UI**: Clean, dark-themed interface with gradient accents

## Live Demo

🌐 **https://analyzer.tellmemo.io**

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

1. User enters a public GitHub repository URL
2. App fetches the repository code via GitHub API
3. Code is sent to OpenAI GPT-4o-mini with specialized prompts
4. AI analyzes the code and returns structured findings with exact file locations
5. Results are displayed with clickable file paths and line numbers
6. Users can click links to view the vulnerable code on GitHub
7. Each issue includes a Claude Code prompt to fix it

## Security Notes

- **Never commit `.env` file** - It contains sensitive API keys
- API keys are loaded at runtime from `.env`
- For production, use environment variables or secure secret management
- `.env` is already added to `.gitignore`

## Technologies Used

- **Flutter Web** with WASM support
- **Riverpod** for state management
- **OpenAI GPT-4o-mini** for AI analysis
- **GitHub API** for repository access
- **Nginx** with SSL/TLS for production hosting
- **Let's Encrypt** for SSL certificates

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

---

Made with ❤️ by [Tell-Me-Mo](https://github.com/Tell-Me-Mo)
