# AI Chatbot for Salesforce

A custom Salesforce-integrated AI chatbot that allows users to interact with powerful language models from OpenAI and Anthropic directly within the Salesforce platform.

## 🚀 Features

- **Seamless Salesforce Deployment**: Built using Lightning Web Components (LWC) and Apex for native Salesforce integration.
- **Multi-Model Support**: Users can choose from a variety of cutting-edge AI models:
  - **OpenAI**:
    - `gpt-4.1`
    - `gpt-4o`
  - **Anthropic**:
    - `claude-3-opus-20240229` (CLAUDE_OPUS_4)
    - `claude-3-sonnet-20240229` (CLAUDE_SONNET_4)
    - `claude-3-sonnet-20230718` (CLAUDE_SONNET_37)
    - Web search-enhanced Claude models (if enabled)

- **Dynamic Model Switching**: End users can choose the AI model in real time through a user-friendly interface.
- **Prompt Customization**: Modify prompts and temperature settings directly from the Salesforce UI.
- **External Credentials**: Uses Salesforce Named Credentials and External Credentials for secure API authentication.

## 🧩 Tech Stack

- **Frontend**: Lightning Web Components (LWC), JavaScript, HTML, CSS
- **Backend**: Apex (Salesforce)
- **APIs**: OpenAI, Anthropic (Claude)
- **Authentication**: OAuth and API key via Salesforce Named & External Credentials

## 📦 Setup Instructions

1. **Clone this repository**:
   ```bash
   git clone https://github.com/MeihaoC/AI-Chatbot.git
   cd AI-Chatbot

