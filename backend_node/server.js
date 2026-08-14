const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/agrivision';

app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB successfully connected!'))
  .catch(err => {
    console.error('MongoDB connection error, running in memory-simulated database mode:', err.message);
  });

// Schemas & Models
const chatMessageSchema = new mongoose.Schema({
  text: { type: String, required: true },
  isUser: { type: Boolean, required: true },
  timestamp: { type: Date, default: Date.now }
});

const chatThreadSchema = new mongoose.Schema({
  label: { type: String, required: true, default: 'New Discussion' },
  messages: [chatMessageSchema]
});

const ChatThread = mongoose.model('ChatThread', chatThreadSchema);

// Diagnostic advisory response parser (ported from Darts chat service)
function getAdvisoryResponse(userMessage) {
  const msg = userMessage.toLowerCase();

  if (msg.containsAny(['tomato', 'early blight', 'late blight'])) {
    return "For Tomato Blight, remove infected leaves immediately. Spray copper-based fungicides or bio-fungicides (Bacillus subtilis). Ensure you water only the soil, not the leaves, to keep humidity low around the plants.";
  }
  if (msg.containsAny(['potato', 'tuber'])) {
    return "Potato plants thrive in well-drained soil. Watch out for Early Blight (target-like spots). Ensure crop rotation is practiced and use certified disease-free seed tubers.";
  }
  if (msg.containsAny(['rice', 'blast', 'blight'])) {
    return "Rice Blast can be devastating. Avoid applying excess nitrogen fertilizer, which increases infection rates. Maintain optimal flooding in the field and use blast-resistant seeds.";
  }
  if (msg.containsAny(['chili', 'curl', 'whitefly'])) {
    return "Chili leaf curl is viral and spread by whiteflies. To manage it, spray organic neem oil or soapy water to control whiteflies, and pull out highly infected plants to stop the virus from spreading.";
  }
  if (msg.containsAny(['fertilizer', 'urea', 'npk'])) {
    return "A standard NPK (Nitrogen-Phosphorus-Potassium) balance is key. Sucking pests love nitrogen-heavy, succulent leaves. For fruiting stages (tomato, chili), increase Potassium (K) to support strong fruit skin and disease resistance.";
  }
  if (msg.containsAny(['weather', 'rain'])) {
    return "Always check the local forecast before spraying pesticides or applying fertilizer. Heavy rains will wash them off. If rain is expected, ensure your drainage channels are clear to prevent waterlogging.";
  }
  if (msg.containsAny(['organic', 'neem', 'natural'])) {
    return "Organic farming utilizes bio-control methods. Neem oil (1% dilution with a few drops of dish soap) is excellent for sucking pests. Bacillus thuringiensis (Bt) is great for caterpillars. Composted cow manure builds soil immunity.";
  }
  if (msg.containsAny(['hello', 'hi', 'hey'])) {
    return "Hello! I am AgriVision's AI Assistant. You can ask me about crop diseases, pest controls, fertilizers, watering advice, or how to use our scanning features. How can I help you today?";
  }

  return "Thank you for sharing that. To best assist you with your crops, could you tell me which crop you are growing (e.g., Tomato, Rice, Chili) or describe the symptoms you are seeing on the leaves?";
}

// Helper utility
String.prototype.containsAny = function(keywords) {
  return keywords.some(kw => this.includes(kw));
};

// Memory fallback database for offline/no-mongo simulation
let simulatedDatabase = [];

// API endpoints
app.get('/api/threads', async (req, res) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const threads = await ChatThread.find().select('label _id');
      return res.json(threads.map(t => ({ id: t._id, label: t.label })));
    } else {
      return res.json(simulatedDatabase.map(t => ({ id: t.id, label: t.label })));
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/threads', async (req, res) => {
  try {
    const { label } = req.body;
    const initialWelcomeMessage = {
      text: "Hello! I am AgriVision's AI Assistant. You can ask me about crop diseases, pest controls, fertilizers, watering advice, or how to use our scanning features. How can I help you today?",
      isUser: false,
      timestamp: new Date()
    };

    if (mongoose.connection.readyState === 1) {
      const newThread = new ChatThread({
        label: label || 'New Discussion',
        messages: [initialWelcomeMessage]
      });
      await newThread.save();
      res.status(201).json({ id: newThread._id, label: newThread.label, messages: newThread.messages });
    } else {
      const newThread = {
        id: Date.now().toString(),
        label: label || 'New Discussion',
        messages: [initialWelcomeMessage]
      };
      simulatedDatabase.push(newThread);
      res.status(201).json(newThread);
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/threads/:id/messages', async (req, res) => {
  try {
    const { id } = req.params;
    if (mongoose.connection.readyState === 1) {
      const thread = await ChatThread.findById(id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });
      res.json(thread.messages);
    } else {
      const thread = simulatedDatabase.find(t => t.id === id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });
      res.json(thread.messages);
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/threads/:id/messages', async (req, res) => {
  try {
    const { id } = req.params;
    const { text } = req.body;

    if (!text) return res.status(400).json({ error: 'Message text is required' });

    const userMessage = {
      text: text,
      isUser: true,
      timestamp: new Date()
    };

    // Calculate bot advisory response
    const botAdvisory = getAdvisoryResponse(text);
    const botMessage = {
      text: botAdvisory,
      isUser: false,
      timestamp: new Date()
    };

    if (mongoose.connection.readyState === 1) {
      const thread = await ChatThread.findById(id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });

      // Auto rename thread if it has default label
      if (thread.label === 'New Discussion' || thread.label === 'Welcome Conversation') {
        const words = text.split(' ');
        const title = words.take(4).join(' ');
        thread.label = title.length > 24 ? title.substring(0, 22) + '...' : title;
      }

      thread.messages.push(userMessage);
      thread.messages.push(botMessage);
      await thread.save();

      res.status(201).json({ userMessage, botMessage });
    } else {
      const thread = simulatedDatabase.find(t => t.id === id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });

      if (thread.label === 'New Discussion' || thread.label === 'Welcome Conversation') {
        thread.label = text.split(' ').slice(0, 4).join(' ');
      }

      thread.messages.push(userMessage);
      thread.messages.push(botMessage);

      res.status(201).json({ userMessage, botMessage });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/threads/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { label } = req.body;

    if (!label) return res.status(400).json({ error: 'Label is required' });

    if (mongoose.connection.readyState === 1) {
      const thread = await ChatThread.findByIdAndUpdate(id, { label }, { new: true });
      if (!thread) return res.status(404).json({ error: 'Thread not found' });
      res.json({ id: thread._id, label: thread.label });
    } else {
      const thread = simulatedDatabase.find(t => t.id === id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });
      thread.label = label;
      res.json({ id: thread.id, label: thread.label });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/threads/:id', async (req, res) => {
  try {
    const { id } = req.params;
    if (mongoose.connection.readyState === 1) {
      const thread = await ChatThread.findByIdAndDelete(id);
      if (!thread) return res.status(404).json({ error: 'Thread not found' });
      res.json({ success: true, message: 'Thread deleted' });
    } else {
      const idx = simulatedDatabase.findIndex(t => t.id === id);
      if (idx === -1) return res.status(404).json({ error: 'Thread not found' });
      simulatedDatabase.splice(idx, 1);
      res.json({ success: true, message: 'Thread deleted' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`AgriVision Node.js backend listening on port ${PORT}`);
});
