class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatService {
  Future<String> getResponse(String userMessage) async {
    // Simulate AI thinking delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final msg = userMessage.toLowerCase();

    if (msg.contains('tomato') || msg.contains('early blight') || msg.contains('late blight')) {
      return "For Tomato Blight, remove infected leaves immediately. Spray copper-based fungicides or bio-fungicides (Bacillus subtilis). Ensure you water only the soil, not the leaves, to keep humidity low around the plants.";
    }

    if (msg.contains('potato') || msg.contains('tuber')) {
      return "Potato plants thrive in well-drained soil. Watch out for Early Blight (target-like spots). Ensure crop rotation is practiced and use certified disease-free seed tubers.";
    }

    if (msg.contains('rice') || msg.contains('blast') || msg.contains('blight')) {
      return "Rice Blast can be devastating. Avoid applying excess nitrogen fertilizer, which increases infection rates. Maintain optimal flooding in the field and use blast-resistant seeds.";
    }

    if (msg.contains('chili') || msg.contains('curl') || msg.contains('whitefly')) {
      return "Chili leaf curl is viral and spread by whiteflies. To manage it, spray organic neem oil or soapy water to control whiteflies, and pull out highly infected plants to stop the virus from spreading.";
    }

    if (msg.contains('fertilizer') || msg.contains('urea') || msg.contains('npk')) {
      return "A standard NPK (Nitrogen-Phosphorus-Potassium) balance is key. Sucking pests love nitrogen-heavy, succulent leaves. For fruiting stages (tomato, chili), increase Potassium (K) to support strong fruit skin and disease resistance.";
    }

    if (msg.contains('weather') || msg.contains('rain')) {
      return "Always check the local forecast before spraying pesticides or applying fertilizer. Heavy rains will wash them off. If rain is expected, ensure your drainage channels are clear to prevent waterlogging.";
    }

    if (msg.contains('organic') || msg.contains('neem') || msg.contains('natural')) {
      return "Organic farming utilizes bio-control methods. Neem oil (1% dilution with a few drops of dish soap) is excellent for sucking pests. Bacillus thuringiensis (Bt) is great for caterpillars. Composted cow manure builds soil immunity.";
    }

    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return "Hello! I am AgriVision's AI Assistant. You can ask me about crop diseases, pest controls, fertilizers, watering advice, or how to use our scanning features. How can I help you today?";
    }

    // Default response
    return "Thank you for sharing that. To best assist you with your crops, could you tell me which crop you are growing (e.g., Tomato, Rice, Chili) or describe the symptoms you are seeing on the leaves?";
  }
}
