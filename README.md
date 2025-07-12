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
- **External Credentials**: Uses Salesforce Custom Settings for secure API authentication.

## 🧩 Tech Stack

- **Frontend**: Lightning Web Components (LWC), JavaScript, HTML, CSS
- **Backend**: Apex (Salesforce)
- **APIs**: OpenAI, Anthropic (Claude)
- **Authentication**: OAuth and API key via Salesforce Custom Settings

## 📹 Demo
<img width="473" height="522" alt="Screenshot 2025-07-12 at 4 07 02 PM" src="https://github.com/user-attachments/assets/c4a49e92-f685-4d21-9a85-656740690315" />
<img width="464" height="505" alt="Screenshot 2025-07-12 at 4 07 38 PM" src="https://github.com/user-attachments/assets/d12a67bb-3ce4-4c4d-88e4-cdec74c8f9c8" />
<img width="474" height="518" alt="Screenshot 2025-07-12 at 4 08 47 PM" src="https://github.com/user-attachments/assets/3028e465-f710-4dbb-9cd5-4194e2e79a7d" />

## 📦 Setup Instructions

1. **Clone this repository**:
   ```bash
   git clone https://github.com/MeihaoC/AI-Chatbot.git
   cd AI-Chatbot

