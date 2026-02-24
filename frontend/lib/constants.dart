const String kBackendUrl = "https://cikgu-ai-backend.onrender.com";

// Set to true to bypass Firebase and Backend during quota limits
const bool kUseDemoMode = true;

const Map<String, dynamic> kMockHierarchy = {
  "Form 4": {
    "Sejarah": "sejarah_f4",
  },
  "Form 5": {
    "Physics": "physics_f5",
  },
};

const Map<String, dynamic> kMockChapters = {
  "chapters": {
    "Bab 1": 10,
    "Bab 2": 28,
    "Bab 3": 58,
  },
  "pdf_drive_link": "https://example.com/demo.pdf",
  "title": "Module (Demo Mode)"
};
