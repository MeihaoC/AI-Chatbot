# ChatGPT Interface LWC

A Lightning Web Component that provides a ChatGPT-like interface for Salesforce, allowing users to interact with AI models through a chat interface.

## Features

- **Model Selection**: Choose from different AI models (GPT-3.5, GPT-4, Claude, etc.)
- **Temperature Control**: Adjust creativity/randomness with a slider (0-2)
- **Real-time Chat**: Send messages and receive AI responses
- **Loading States**: Visual feedback during API calls
- **Responsive Design**: Works on desktop and mobile devices
- **Modern UI**: Clean, modern interface with animations

## Setup Instructions

### 1. Deploy the Components

Deploy the following files to your Salesforce org:
- `chatGptInterface/` (LWC component)
- `ChatGPTService.cls` (Apex service class)
- `ChatGPTServiceTest.cls` (Test class)

### 2. Configure API Access

#### Option A: Using Named Credentials (Recommended)

1. Go to **Setup** → **Security** → **Named Credentials**
2. Create a new Named Credential:
   - **Label**: ChatGPT API
   - **Name**: ChatGPT_API
   - **URL**: `https://api.openai.com`
   - **Identity Type**: Named Principal
   - **Authentication Protocol**: Password Authentication
   - **Username**: Your API key
   - **Password**: (leave blank)

#### Option B: Using Custom Settings

1. Create a Custom Setting to store your API key securely
2. Update the `getServiceConfig` method in `ChatGPTService.cls`

### 3. Update the Apex Service

Edit `ChatGPTService.cls` and update the `getServiceConfig` method:

```apex
private static AIServiceConfig getServiceConfig(String model, Decimal temperature) {
    // Replace with your actual API key and endpoint
    String apiKey = 'your-actual-api-key';
    String endpoint = 'https://api.openai.com/v1/chat/completions';
    
    return new AIServiceConfig(apiKey, endpoint, model, temperature);
}
```

### 4. Add to Your Page

1. Go to **Setup** → **Lightning App Builder**
2. Edit the page where you want to add the component
3. Drag the **ChatGPT Interface** component to your page
4. Save and activate the page

## Usage

1. **Select Model**: Choose your preferred AI model from the dropdown
2. **Adjust Temperature**: Use the slider to control response creativity (0 = focused, 2 = creative)
3. **Type Message**: Enter your question or prompt in the text area
4. **Send**: Click the Send button or press Enter to submit
5. **View Response**: The AI response will appear in the chat interface

## Customization

### Adding New Models

Edit the `modelOptions` getter in `chatGptInterface.js`:

```javascript
get modelOptions() {
    return [
        { label: 'Your Model', value: 'your-model-id' },
        // ... existing models
    ];
}
```

### Styling

Modify `chatGptInterface.css` to customize the appearance:

- Colors and themes
- Layout and spacing
- Animations and transitions
- Responsive breakpoints

### API Integration

The component is designed to work with OpenAI's API but can be adapted for other AI services by modifying the `ChatGPTService.cls` file.

## Security Considerations

- Store API keys securely using Named Credentials or Custom Settings
- Implement proper error handling and rate limiting
- Consider implementing user authentication and authorization
- Monitor API usage and costs

## Troubleshooting

### Common Issues

1. **API Call Fails**: Check your API key and endpoint configuration
2. **Component Not Loading**: Ensure all files are deployed correctly
3. **Styling Issues**: Check for CSS conflicts with other components

### Debug Mode

Enable debug logs in Salesforce to troubleshoot API calls:
1. Go to **Setup** → **Environments** → **Debug Logs**
2. Add your user to the debug log list
3. Test the component and check the logs

## Support

For issues or questions:
1. Check the debug logs for error messages
2. Verify your API configuration
3. Test the connection using the `testConnection` method

## License

This component is provided as-is for educational and development purposes. 