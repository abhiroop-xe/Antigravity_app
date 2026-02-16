# Nebula v1 - Secure Lead Intelligence Engine

Nebula v1 is a high-performance, secure lead research and enrichment platform built with Flutter. It streamlines the sales and marketing workflow by providing instant AI-powered insights while maintaining strict data privacy standards.

## 🚀 Core Features

- **AI-Powered Enrichment**: Double-layered enrichment using Mistral AI and Google Gemini.
- **Privacy First (PII Scrubbing)**: Automatically hashes and removes Personally Identifiable Information (PII) before sending data to AI providers.
- **Smart Data Governance**: Comprehensive audit trails and usage reporting to ensure compliance and transparency.
- **Token Saving Mode**: Integrated "AI Limited" mode for cost-effective testing and development.
- **Optimized Web Experience**: Leverages Flutter's HTML renderer for a lightweight, fast-loading interface.
- **Supabase Integration**: Robust real-time backend with secure authentication and data storage.

## 🛠 Tech Stack

- **Frontend**: Flutter (3.24.5+)
- **Backend**: Supabase (Auth, DB, Storage)
- **AI Models**: Mistral AI (Primary), Google Gemini (Secondary/Fallback)
- **State Management**: Provider
- **Routing**: GoRouter

## 📦 Getting Started

### Prerequisites
- Flutter SDK (Web support enabled)
- No Java required for Web deployment

### Configuration
1. Create a `.env` file in the root directory.
2. Add your credentials:
   ```env
   SUPABASE_URL=your_url
   SUPABASE_ANON_KEY=your_key
   MISTRAL_API_KEY=your_mistral_key
   GEMINI_API_KEY=your_gemini_key
   ```

### Running Locally
```bash
flutter run -d chrome
```

## 🚢 Deployment (GitHub Pages)

The project includes a deployment script for quick updates to GitHub Pages:

```bash
sh deploy_gh_pages.sh
```

## 🔒 Security & Governance

Nebula v1 includes a dedicated **Governance Section** that provides:
- Data Provenance tracking
- Token usage analytics
- Privacy scrubbing verification
- Hash-based audit trails

---
*Built with ❤️ for secure sales intelligence.*
