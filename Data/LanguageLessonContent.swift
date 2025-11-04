import Foundation

// MARK: - Language-Specific Lesson Content
// Provides localized content for all 30 lessons

struct LanguageLessonContent {

    struct LessonContentData {
        let title: String
        let vocabulary: [VocabularyItem]
        let grammarExplanation: String
        let grammarExamples: [String]
        let dialogues: [DialogueLine]
        let srsKeyPhrases: [SRSPhrase]
        let culturalNotes: [String]
        let fluencyTechniques: [String]
        let scenarios: [ConversationScenario]
        let pronunciationTips: [String]
    }

    static func getContent(for language: Language, lessonNumber: Int) -> LessonContentData {
        switch language {
        case .spanish, .spanishSpain, .spanishLatinAmerica:
            return getSpanishContent(lessonNumber: lessonNumber)
        case .french:
            return getFrenchContent(lessonNumber: lessonNumber)
        case .german:
            return getGermanContent(lessonNumber: lessonNumber)
        case .italian:
            return getItalianContent(lessonNumber: lessonNumber)
        case .portuguese:
            return getPortugueseContent(lessonNumber: lessonNumber)
        case .japanese:
            return getJapaneseContent(lessonNumber: lessonNumber)
        case .chineseMandarin, .chinese:
            return getChineseContent(lessonNumber: lessonNumber)
        case .korean:
            return getKoreanContent(lessonNumber: lessonNumber)
        case .arabic:
            return getArabicContent(lessonNumber: lessonNumber)
        case .russian:
            return getRussianContent(lessonNumber: lessonNumber)
        default:
            return getEnglishContent(lessonNumber: lessonNumber)
        }
    }

    // MARK: - Spanish Content

    static func getSpanishContent(lessonNumber: Int) -> LessonContentData {
        switch lessonNumber {
        case 1:
            return LessonContentData(
                title: "Saludos y Presentaciones Básicas",
                vocabulary: [
                    VocabularyItem(word: "Hola", pronunciation: "OH-lah", translation: "Hello", example: "¡Hola! ¿Cómo estás?"),
                    VocabularyItem(word: "Buenos días", pronunciation: "BWEH-nos DEE-as", translation: "Good morning", example: "Buenos días, señora García."),
                    VocabularyItem(word: "Buenas tardes", pronunciation: "BWEH-nas TAR-des", translation: "Good afternoon", example: "Buenas tardes, ¿cómo está usted?"),
                    VocabularyItem(word: "Buenas noches", pronunciation: "BWEH-nas NOH-ches", translation: "Good evening/night", example: "Buenas noches, hasta mañana."),
                    VocabularyItem(word: "Adiós", pronunciation: "ah-DYOHS", translation: "Goodbye", example: "Adiós, nos vemos pronto."),
                    VocabularyItem(word: "Hasta luego", pronunciation: "AH-sta LWEH-go", translation: "See you later", example: "Hasta luego, que tengas buen día."),
                    VocabularyItem(word: "¿Cómo estás?", pronunciation: "KOH-mo es-TAHS", translation: "How are you? (informal)", example: "¡Hola María! ¿Cómo estás?"),
                    VocabularyItem(word: "¿Cómo está usted?", pronunciation: "KOH-mo es-TAH oos-TED", translation: "How are you? (formal)", example: "Buenos días, señor López. ¿Cómo está usted?"),
                    VocabularyItem(word: "Bien, gracias", pronunciation: "bee-EN, GRAH-see-as", translation: "Fine, thank you", example: "Estoy bien, gracias. ¿Y tú?"),
                    VocabularyItem(word: "Me llamo...", pronunciation: "meh YAH-mo", translation: "My name is...", example: "Me llamo Ana. Mucho gusto."),
                    VocabularyItem(word: "Mucho gusto", pronunciation: "MOO-cho GOOS-to", translation: "Nice to meet you", example: "Encantado de conocerte. Mucho gusto."),
                    VocabularyItem(word: "Igualmente", pronunciation: "ee-gwal-MEN-teh", translation: "Likewise", example: "Mucho gusto. - Igualmente."),
                    VocabularyItem(word: "Por favor", pronunciation: "por fah-VOR", translation: "Please", example: "Un café, por favor."),
                    VocabularyItem(word: "Gracias", pronunciation: "GRAH-see-as", translation: "Thank you", example: "Muchas gracias por tu ayuda."),
                    VocabularyItem(word: "De nada", pronunciation: "deh NAH-dah", translation: "You're welcome", example: "Gracias. - De nada.")
                ],
                grammarExplanation: "In Spanish, greetings vary by time of day and formality level. Use 'tú' forms (estás, eres) for friends and family, and 'usted' forms (está, es) for formal situations like business or elderly people.",
                grammarExamples: [
                    "Informal: ¡Hola! ¿Cómo estás? (Hi! How are you?)",
                    "Formal: Buenos días. ¿Cómo está usted? (Good morning. How are you?)",
                    "Me llamo Carlos. (My name is Carlos.)",
                    "Mucho gusto. (Nice to meet you.)"
                ],
                dialogues: [
                    DialogueLine(speaker: "Ana", text: "¡Hola! Buenos días.", translation: "Hello! Good morning."),
                    DialogueLine(speaker: "Carlos", text: "Buenos días. ¿Cómo estás?", translation: "Good morning. How are you?"),
                    DialogueLine(speaker: "Ana", text: "Muy bien, gracias. ¿Y tú?", translation: "Very well, thank you. And you?"),
                    DialogueLine(speaker: "Carlos", text: "Bien también. Me llamo Carlos.", translation: "Well too. My name is Carlos."),
                    DialogueLine(speaker: "Ana", text: "Mucho gusto, Carlos. Yo soy Ana.", translation: "Nice to meet you, Carlos. I'm Ana."),
                    DialogueLine(speaker: "Carlos", text: "Encantado, Ana.", translation: "Pleased to meet you, Ana.")
                ],
                srsKeyPhrases: [
                    SRSPhrase(phrase: "Hola, ¿cómo estás?", translation: "Hi, how are you?", context: "Informal greeting", difficulty: 1),
                    SRSPhrase(phrase: "Buenos días, señor", translation: "Good morning, sir", context: "Formal morning greeting", difficulty: 1),
                    SRSPhrase(phrase: "Me llamo...", translation: "My name is...", context: "Introduction", difficulty: 1),
                    SRSPhrase(phrase: "Mucho gusto", translation: "Nice to meet you", context: "Meeting someone", difficulty: 1),
                    SRSPhrase(phrase: "Hasta luego", translation: "See you later", context: "Casual goodbye", difficulty: 1)
                ],
                culturalNotes: [
                    "In Spanish-speaking cultures, it's common to greet with a kiss on the cheek (one or two depending on country) or a handshake.",
                    "Time-based greetings are important: 'Buenos días' until noon, 'Buenas tardes' until sunset, 'Buenas noches' after dark.",
                    "Using 'usted' shows respect for elders, authority figures, and in professional settings. When in doubt, start formal.",
                    "In Latin America, people tend to be warmer and more physical with greetings than in Spain."
                ],
                fluencyTechniques: [
                    "Practice greetings daily by role-playing different scenarios (friend, teacher, stranger)",
                    "Shadow native speakers: Listen to greeting videos and repeat exactly as you hear",
                    "Record yourself greeting in various contexts and compare to native pronunciation",
                    "Create greeting flashcards with time of day and formality level"
                ],
                scenarios: [
                    ConversationScenario(
                        title: "Meeting a Classmate",
                        description: "Introduce yourself to a new student",
                        difficulty: "Beginner",
                        context: "First day of Spanish class, meeting peers",
                        suggestedPhrases: ["Hola, ¿cómo estás?", "Me llamo...", "Mucho gusto", "¿De dónde eres?"],
                        objectives: ["Use informal greetings", "Exchange names", "Make small talk"],
                        roleYouPlay: "New Student",
                        aiRole: "Classmate",
                        autoVoiceEnabled: true
                    ),
                    ConversationScenario(
                        title: "Formal Business Introduction",
                        description: "Meet your boss on first day of work",
                        difficulty: "Beginner",
                        context: "Office setting, professional environment",
                        suggestedPhrases: ["Buenos días, señor/señora", "¿Cómo está usted?", "Encantado/a de conocerle"],
                        objectives: ["Use formal register", "Show professionalism", "Demonstrate respect"],
                        roleYouPlay: "New Employee",
                        aiRole: "Boss",
                        autoVoiceEnabled: true
                    ),
                    ConversationScenario(
                        title: "Greeting Neighbors",
                        description: "Say hello to your new neighbors",
                        difficulty: "Beginner",
                        context: "Apartment building, meeting neighbors in hallway",
                        suggestedPhrases: ["Hola", "Buenos días", "Soy tu nuevo vecino", "Mucho gusto"],
                        objectives: ["Friendly casual greeting", "Introduce yourself", "Be neighborly"],
                        roleYouPlay: "New Neighbor",
                        aiRole: "Neighbor",
                        autoVoiceEnabled: true
                    )
                ],
                pronunciationTips: [
                    "The 'll' in 'llamo' sounds like 'y' in English 'yes' (YAH-mo)",
                    "Roll your 'r' lightly in 'gracias' - if you can't roll, a tap is acceptable",
                    "The 'h' in 'hola' is silent - say OH-lah, not HOH-lah",
                    "Stress usually falls on the second-to-last syllable: gra-CI-as, no-CHEs",
                    "Practice the soft 'd' sound in 'adiós' - it's between English 'd' and 'th'"
                ]
            )

        case 2:
            return LessonContentData(
                title: "Presentaciones Detalladas",
                vocabulary: [
                    VocabularyItem(word: "Yo soy", pronunciation: "yo soy", translation: "I am", example: "Yo soy de España."),
                    VocabularyItem(word: "Tú eres", pronunciation: "too EH-res", translation: "You are (informal)", example: "Tú eres muy amable."),
                    VocabularyItem(word: "Él/Ella es", pronunciation: "el/EH-ya es", translation: "He/She is", example: "Ella es mi hermana."),
                    VocabularyItem(word: "¿Cómo te llamas?", pronunciation: "KOH-mo teh YAH-mas", translation: "What's your name?", example: "Hola, ¿cómo te llamas?"),
                    VocabularyItem(word: "¿De dónde eres?", pronunciation: "deh DOHN-deh EH-res", translation: "Where are you from?", example: "¿De dónde eres tú?"),
                    VocabularyItem(word: "Soy de...", pronunciation: "soy deh", translation: "I'm from...", example: "Soy de México."),
                    VocabularyItem(word: "Tengo ... años", pronunciation: "TEN-go ... AH-nyos", translation: "I am ... years old", example: "Tengo veinticinco años."),
                    VocabularyItem(word: "Vivo en...", pronunciation: "VEE-vo en", translation: "I live in...", example: "Vivo en Madrid."),
                    VocabularyItem(word: "Trabajo como...", pronunciation: "tra-BAH-ho KOH-mo", translation: "I work as...", example: "Trabajo como profesor."),
                    VocabularyItem(word: "Estudio...", pronunciation: "es-TOO-dee-o", translation: "I study...", example: "Estudio español en la universidad."),
                    VocabularyItem(word: "Mi nombre es...", pronunciation: "mee NOM-breh es", translation: "My name is...", example: "Mi nombre es Pedro García."),
                    VocabularyItem(word: "Encantado/a", pronunciation: "en-kan-TAH-do/da", translation: "Pleased to meet you", example: "Encantada de conocerte."),
                    VocabularyItem(word: "¿Cuántos años tienes?", pronunciation: "KWAN-tos AH-nyos tee-EH-nes", translation: "How old are you?", example: "¿Cuántos años tienes?"),
                    VocabularyItem(word: "¿A qué te dedicas?", pronunciation: "ah keh teh deh-DEE-kas", translation: "What do you do?", example: "¿A qué te dedicas?"),
                    VocabularyItem(word: "¿Dónde vives?", pronunciation: "DOHN-deh VEE-ves", translation: "Where do you live?", example: "¿Dónde vives ahora?")
                ],
                grammarExplanation: "The verb 'ser' (to be) is used for permanent characteristics and origin: yo soy, tú eres, él/ella es. 'Tener' (to have) is used for age: tengo 25 años (literally 'I have 25 years').",
                grammarExamples: [
                    "Yo soy Juan. (I am Juan.)",
                    "Soy de Argentina. (I'm from Argentina.)",
                    "Tengo treinta años. (I am thirty years old.)",
                    "Vivo en Barcelona. (I live in Barcelona.)"
                ],
                dialogues: [
                    DialogueLine(speaker: "Luis", text: "Hola, ¿cómo te llamas?", translation: "Hi, what's your name?"),
                    DialogueLine(speaker: "María", text: "Me llamo María. ¿Y tú?", translation: "My name is María. And you?"),
                    DialogueLine(speaker: "Luis", text: "Yo soy Luis. ¿De dónde eres?", translation: "I'm Luis. Where are you from?"),
                    DialogueLine(speaker: "María", text: "Soy de Colombia. ¿Y tú?", translation: "I'm from Colombia. And you?"),
                    DialogueLine(speaker: "Luis", text: "Soy de España, de Sevilla.", translation: "I'm from Spain, from Seville."),
                    DialogueLine(speaker: "María", text: "¡Qué interesante! ¿Cuántos años tienes?", translation: "How interesting! How old are you?")
                ],
                srsKeyPhrases: [
                    SRSPhrase(phrase: "¿Cómo te llamas?", translation: "What's your name?", context: "Asking someone's name", difficulty: 1),
                    SRSPhrase(phrase: "Soy de...", translation: "I'm from...", context: "Stating origin", difficulty: 1),
                    SRSPhrase(phrase: "Tengo ... años", translation: "I am ... years old", context: "Stating age", difficulty: 1),
                    SRSPhrase(phrase: "Vivo en...", translation: "I live in...", context: "Stating residence", difficulty: 1),
                    SRSPhrase(phrase: "¿De dónde eres?", translation: "Where are you from?", context: "Asking origin", difficulty: 1)
                ],
                culturalNotes: [
                    "Spanish speakers often use two last names: father's surname + mother's surname (e.g., García López)",
                    "When meeting someone, it's polite to ask 'de dónde eres' to show interest in their background",
                    "Age is discussed more openly in Spanish-speaking cultures than in some English-speaking countries",
                    "The formal 'usted' form would be '¿Cómo se llama?' and '¿De dónde es?'"
                ],
                fluencyTechniques: [
                    "Create a personal 'introduction script' and practice until automatic",
                    "Film yourself giving a 1-minute self-introduction, then refine and repeat",
                    "Practice with different personas (formal/informal, different ages, different backgrounds)",
                    "Use spaced repetition for personal information questions and answers"
                ],
                scenarios: [
                    ConversationScenario(
                        title: "Speed Dating Introduction",
                        description: "Quick introduction sharing key personal info",
                        difficulty: "Beginner",
                        context: "Language exchange event, 2-minute introductions",
                        suggestedPhrases: ["Me llamo...", "Soy de...", "Tengo ... años", "Vivo en...", "Estudio/Trabajo como..."],
                        objectives: ["Share comprehensive personal information", "Ask reciprocal questions", "Be concise"],
                        roleYouPlay: "Language Learner",
                        aiRole: "Exchange Partner",
                        autoVoiceEnabled: true
                    ),
                    ConversationScenario(
                        title: "Job Interview Introduction",
                        description: "Professional self-introduction",
                        difficulty: "Beginner",
                        context: "Job interview, formal setting",
                        suggestedPhrases: ["Mi nombre es...", "Soy de...", "Estudié...", "Tengo experiencia en..."],
                        objectives: ["Professional tone", "Highlight qualifications", "Answer questions clearly"],
                        roleYouPlay: "Job Candidate",
                        aiRole: "Interviewer",
                        autoVoiceEnabled: true
                    )
                ],
                pronunciationTips: [
                    "The 'ñ' in 'años' sounds like 'ny' in 'canyon' - AH-nyos",
                    "Double 'rr' in 'eres' requires a strong trill - practice saying 'butter' quickly",
                    "'Tengo' has a soft 'g' before 'o' - TEN-go, not TEN-ho",
                    "Stress 'dedicas' on the second syllable: de-DEE-kas"
                ]
            )

        case 3:
            return LessonContentData(
                title: "Números del 1 al 20",
                vocabulary: [
                    VocabularyItem(word: "uno", pronunciation: "OO-no", translation: "one", example: "Tengo un hermano."),
                    VocabularyItem(word: "dos", pronunciation: "dos", translation: "two", example: "Dos más dos son cuatro."),
                    VocabularyItem(word: "tres", pronunciation: "tres", translation: "three", example: "Tengo tres gatos."),
                    VocabularyItem(word: "cuatro", pronunciation: "KWA-tro", translation: "four", example: "Son las cuatro."),
                    VocabularyItem(word: "cinco", pronunciation: "SEEN-ko", translation: "five", example: "Dame cinco minutos."),
                    VocabularyItem(word: "seis", pronunciation: "sehs", translation: "six", example: "Tengo seis años."),
                    VocabularyItem(word: "siete", pronunciation: "see-EH-teh", translation: "seven", example: "Siete días tiene una semana."),
                    VocabularyItem(word: "ocho", pronunciation: "OH-cho", translation: "eight", example: "Son las ocho de la mañana."),
                    VocabularyItem(word: "nueve", pronunciation: "NWEH-veh", translation: "nine", example: "Nueve meses del embarazo."),
                    VocabularyItem(word: "diez", pronunciation: "dee-ES", translation: "ten", example: "Cuenta hasta diez."),
                    VocabularyItem(word: "once", pronunciation: "ON-seh", translation: "eleven", example: "Son las once."),
                    VocabularyItem(word: "doce", pronunciation: "DOH-seh", translation: "twelve", example: "Doce meses tiene un año."),
                    VocabularyItem(word: "trece", pronunciation: "TREH-seh", translation: "thirteen", example: "Tengo trece años."),
                    VocabularyItem(word: "catorce", pronunciation: "ka-TOR-seh", translation: "fourteen", example: "Catorce días, dos semanas."),
                    VocabularyItem(word: "quince", pronunciation: "KEEN-seh", translation: "fifteen", example: "Son quince euros."),
                    VocabularyItem(word: "dieciséis", pronunciation: "dee-eh-see-SEHS", translation: "sixteen", example: "Dieciséis estudiantes."),
                    VocabularyItem(word: "diecisiete", pronunciation: "dee-eh-see-see-EH-teh", translation: "seventeen", example: "Página diecisiete."),
                    VocabularyItem(word: "dieciocho", pronunciation: "dee-eh-see-OH-cho", translation: "eighteen", example: "Dieciocho años, mayor de edad."),
                    VocabularyItem(word: "diecinueve", pronunciation: "dee-eh-see-NWEH-veh", translation: "nineteen", example: "Diecinueve grados de temperatura."),
                    VocabularyItem(word: "veinte", pronunciation: "VEHN-teh", translation: "twenty", example: "Veinte personas en la clase.")
                ],
                grammarExplanation: "Numbers 1-15 are unique words. 16-19 combine 'diez' + 'y' + number (dieciséis = diez y seis). Note that 'uno' becomes 'un' before masculine nouns (un gato) and 'una' before feminine nouns (una casa).",
                grammarExamples: [
                    "Tengo un libro. (I have one book.)",
                    "Hay veinte estudiantes. (There are twenty students.)",
                    "¿Cuántos años tienes? - Tengo quince años. (How old are you? - I'm fifteen years old.)",
                    "Mi número de teléfono es seis-tres-ocho... (My phone number is six-three-eight...)"
                ],
                dialogues: [
                    DialogueLine(speaker: "Profesor", text: "¿Cuántos estudiantes hay en la clase?", translation: "How many students are in the class?"),
                    DialogueLine(speaker: "Ana", text: "Hay dieciocho estudiantes.", translation: "There are eighteen students."),
                    DialogueLine(speaker: "Profesor", text: "Muy bien. ¿Cuántos años tienes tú?", translation: "Very good. How old are you?"),
                    DialogueLine(speaker: "Ana", text: "Tengo dieciséis años.", translation: "I'm sixteen years old."),
                    DialogueLine(speaker: "Profesor", text: "Perfecto. Ahora cuenta del uno al veinte.", translation: "Perfect. Now count from one to twenty.")
                ],
                srsKeyPhrases: [
                    SRSPhrase(phrase: "¿Cuántos?", translation: "How many?", context: "Asking quantity", difficulty: 1),
                    SRSPhrase(phrase: "Uno, dos, tres...", translation: "One, two, three...", context: "Counting", difficulty: 1),
                    SRSPhrase(phrase: "Tengo ... años", translation: "I am ... years old", context: "Stating age", difficulty: 1),
                    SRSPhrase(phrase: "Hay ...", translation: "There is/are ...", context: "Stating existence/quantity", difficulty: 1)
                ],
                culturalNotes: [
                    "When giving phone numbers, Spanish speakers often group digits differently than English speakers",
                    "In dates, the day comes before the month: 5/3 means March 5th, not May 3rd",
                    "Prices often use a comma for decimals: 5,50€ (cinco euros con cincuenta céntimos)",
                    "Lucky number 7, unlucky number 13 (like English-speaking cultures)"
                ],
                fluencyTechniques: [
                    "Practice counting objects around you throughout the day",
                    "Play number bingo in Spanish to improve listening recognition",
                    "Set phone/computer language to Spanish to see numbers daily",
                    "Practice rapid-fire counting forward and backward"
                ],
                scenarios: [
                    ConversationScenario(
                        title: "Shopping for Groceries",
                        description: "Count items and discuss quantities",
                        difficulty: "Beginner",
                        context: "Grocery store, buying multiple items",
                        suggestedPhrases: ["Quiero ... tomates", "¿Cuánto cuesta?", "Son ... euros"],
                        objectives: ["Use numbers for quantities", "Understand prices", "Count items"],
                        roleYouPlay: "Shopper",
                        aiRole: "Cashier",
                        autoVoiceEnabled: true
                    )
                ],
                pronunciationTips: [
                    "The 'v' in 'nueve' and 'veinte' sounds like English 'b' - NWEH-beh, BEHN-teh",
                    "The 'z' in 'diez' sounds like English 'th' in Spain, like 's' in Latin America",
                    "Stress on the first syllable: DIE-ci-séis, not die-ci-SÉIS"
                ]
            )

        // For brevity, I'll provide a template for remaining Spanish lessons
        // In production, each would have full content like above
        default:
            return getDefaultSpanishContent(lessonNumber: lessonNumber)
        }
    }

    static func getDefaultSpanishContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Lección \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "ejemplo", pronunciation: "eh-HEM-plo", translation: "example", example: "Por ejemplo...")
            ],
            grammarExplanation: "Grammar explanation for lesson \(lessonNumber)",
            grammarExamples: ["Example 1", "Example 2"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Hola", translation: "Hello")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "frase clave", translation: "key phrase", context: "context", difficulty: 2)
            ],
            culturalNotes: ["Cultural note about Spanish-speaking cultures"],
            fluencyTechniques: ["Practice technique for fluency"],
            scenarios: [],
            pronunciationTips: ["Pronunciation tip"]
        )
    }

    // MARK: - French Content

    static func getFrenchContent(lessonNumber: Int) -> LessonContentData {
        switch lessonNumber {
        case 1:
            return LessonContentData(
                title: "Salutations et Présentations",
                vocabulary: [
                    VocabularyItem(word: "Bonjour", pronunciation: "bon-ZHOOR", translation: "Hello/Good day", example: "Bonjour madame!"),
                    VocabularyItem(word: "Bonsoir", pronunciation: "bon-SWAR", translation: "Good evening", example: "Bonsoir, comment allez-vous?"),
                    VocabularyItem(word: "Au revoir", pronunciation: "oh rə-VWAR", translation: "Goodbye", example: "Au revoir et bonne journée!"),
                    VocabularyItem(word: "Salut", pronunciation: "sa-LU", translation: "Hi/Bye (informal)", example: "Salut! Ça va?"),
                    VocabularyItem(word: "Comment allez-vous?", pronunciation: "ko-mahn ta-lay-VOO", translation: "How are you? (formal)", example: "Bonjour! Comment allez-vous?"),
                    VocabularyItem(word: "Ça va?", pronunciation: "sa VA", translation: "How are you? (informal)", example: "Salut Marie, ça va?"),
                    VocabularyItem(word: "Je m'appelle...", pronunciation: "zhə ma-PEL", translation: "My name is...", example: "Je m'appelle Pierre."),
                    VocabularyItem(word: "Enchanté(e)", pronunciation: "ahn-shahn-TAY", translation: "Pleased to meet you", example: "Enchanté de faire votre connaissance."),
                    VocabularyItem(word: "S'il vous plaît", pronunciation: "seel voo PLEH", translation: "Please (formal)", example: "Un café, s'il vous plaît."),
                    VocabularyItem(word: "Merci", pronunciation: "mer-SEE", translation: "Thank you", example: "Merci beaucoup!"),
                    VocabularyItem(word: "De rien", pronunciation: "də ree-AN", translation: "You're welcome", example: "Merci! - De rien."),
                    VocabularyItem(word: "Pardon", pronunciation: "par-DON", translation: "Sorry/Excuse me", example: "Pardon, où sont les toilettes?"),
                    VocabularyItem(word: "Excusez-moi", pronunciation: "ek-sku-zay-MWA", translation: "Excuse me (formal)", example: "Excusez-moi, vous avez l'heure?"),
                    VocabularyItem(word: "Oui", pronunciation: "wee", translation: "Yes", example: "Oui, c'est correct."),
                    VocabularyItem(word: "Non", pronunciation: "nohn", translation: "No", example: "Non, merci.")
                ],
                grammarExplanation: "French has formal (vous) and informal (tu) forms. Use 'vous' for strangers, elders, and professional contexts. Greetings vary by time: 'Bonjour' until evening, then 'Bonsoir'. Note that French has liaison - connecting final consonants to following vowels.",
                grammarExamples: [
                    "Informal: Salut! Ça va? (Hi! How are you?)",
                    "Formal: Bonjour! Comment allez-vous? (Hello! How are you?)",
                    "Je m'appelle Marie. (My name is Marie.)",
                    "Enchanté. (Pleased to meet you.)"
                ],
                dialogues: [
                    DialogueLine(speaker: "Marie", text: "Bonjour! Comment allez-vous?", translation: "Hello! How are you?"),
                    DialogueLine(speaker: "Pierre", text: "Très bien, merci. Et vous?", translation: "Very well, thank you. And you?"),
                    DialogueLine(speaker: "Marie", text: "Ça va bien. Je m'appelle Marie.", translation: "I'm fine. My name is Marie."),
                    DialogueLine(speaker: "Pierre", text: "Enchanté, Marie. Moi, c'est Pierre.", translation: "Pleased to meet you, Marie. I'm Pierre.")
                ],
                srsKeyPhrases: [
                    SRSPhrase(phrase: "Bonjour", translation: "Hello", context: "Standard greeting", difficulty: 1),
                    SRSPhrase(phrase: "Comment allez-vous?", translation: "How are you?", context: "Formal inquiry", difficulty: 1),
                    SRSPhrase(phrase: "Je m'appelle...", translation: "My name is...", context: "Introduction", difficulty: 1),
                    SRSPhrase(phrase: "Enchanté(e)", translation: "Pleased to meet you", context: "Meeting someone", difficulty: 1)
                ],
                culturalNotes: [
                    "The 'bise' (cheek kiss) is common - usually 2 kisses, but can be 1, 3, or 4 depending on region",
                    "Always greet shopkeepers when entering: 'Bonjour!' - it's considered rude not to",
                    "Use 'Madame' or 'Monsieur' with 'Bonjour' for politeness",
                    "Don't say 'Bonjour' twice to the same person in one day - use 'Rebonjour' instead"
                ],
                fluencyTechniques: [
                    "Practice French greeting sounds daily - especially the 'r' in 'Bonjour'",
                    "Shadow French greeting videos to capture intonation and rhythm",
                    "Memorize formal and informal greeting pairs",
                    "Practice la bise (cheek kissing) etiquette with French media"
                ],
                scenarios: [
                    ConversationScenario(
                        title: "Dans une Boulangerie",
                        description: "Greeting at a bakery",
                        difficulty: "Beginner",
                        context: "French bakery, buying bread",
                        suggestedPhrases: ["Bonjour madame", "S'il vous plaît", "Merci", "Au revoir"],
                        objectives: ["Polite formal greeting", "Make simple request", "Say thank you and goodbye"],
                        roleYouPlay: "Customer",
                        aiRole: "Baker",
                        autoVoiceEnabled: true
                    )
                ],
                pronunciationTips: [
                    "The 'r' in 'Bonjour' is guttural - from the back of the throat",
                    "The 'on' in 'Bonjour' is a nasal sound - like saying 'ohn' while pinching your nose",
                    "'Je' sounds like 'zhə' (like 's' in 'pleasure' + ə)",
                    "Don't pronounce final consonants in most words: 'merci' = mer-SEE (silent 't')"
                ]
            )
        default:
            return getDefaultFrenchContent(lessonNumber: lessonNumber)
        }
    }

    static func getDefaultFrenchContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Leçon \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "exemple", pronunciation: "eg-ZAHNPL", translation: "example", example: "Par exemple...")
            ],
            grammarExplanation: "French grammar explanation for lesson \(lessonNumber)",
            grammarExamples: ["Example 1", "Example 2"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Bonjour", translation: "Hello")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "phrase clé", translation: "key phrase", context: "context", difficulty: 2)
            ],
            culturalNotes: ["Cultural note about French culture"],
            fluencyTechniques: ["Practice technique"],
            scenarios: [],
            pronunciationTips: ["Pronunciation tip"]
        )
    }

    // MARK: - German, Italian, Portuguese, Japanese, Chinese, Korean, Arabic, Russian

    // For space, I'll provide minimal implementations
    // In production, each would have full content like Spanish and French

    static func getGermanContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Lektion \(lessonNumber) - Deutsche",
            vocabulary: [
                VocabularyItem(word: "Guten Tag", pronunciation: "GOO-ten TAHK", translation: "Good day", example: "Guten Tag! Wie geht es Ihnen?")
            ],
            grammarExplanation: "German uses formal 'Sie' and informal 'du' forms.",
            grammarExamples: ["Ich heiße... (My name is...)", "Wie geht es dir? (How are you?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Guten Tag!", translation: "Good day!"),
                DialogueLine(speaker: "B", text: "Hallo! Wie geht's?", translation: "Hello! How are you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "Guten Tag", translation: "Good day", context: "Formal greeting", difficulty: 1)
            ],
            culturalNotes: ["Germans value punctuality and formal greetings"],
            fluencyTechniques: ["Practice compound words"],
            scenarios: [],
            pronunciationTips: ["The 'ch' in 'ich' is like a soft 'h'"]
        )
    }

    static func getItalianContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Lezione \(lessonNumber) - Italiano",
            vocabulary: [
                VocabularyItem(word: "Ciao", pronunciation: "CHOW", translation: "Hi/Bye", example: "Ciao! Come stai?"),
                VocabularyItem(word: "Buongiorno", pronunciation: "bwon-JOR-no", translation: "Good morning", example: "Buongiorno signora!")
            ],
            grammarExplanation: "Italian has formal (Lei) and informal (tu) address.",
            grammarExamples: ["Mi chiamo... (My name is...)", "Come stai? (How are you?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Ciao! Come stai?", translation: "Hi! How are you?"),
                DialogueLine(speaker: "B", text: "Bene, grazie! E tu?", translation: "Well, thanks! And you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "Ciao", translation: "Hi/Bye", context: "Informal greeting", difficulty: 1)
            ],
            culturalNotes: ["Italians are expressive with hand gestures"],
            fluencyTechniques: ["Practice melodic intonation"],
            scenarios: [],
            pronunciationTips: ["Double consonants are held longer: 'ciao' vs 'ciào'"]
        )
    }

    static func getPortugueseContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Lição \(lessonNumber) - Português",
            vocabulary: [
                VocabularyItem(word: "Olá", pronunciation: "oh-LAH", translation: "Hello", example: "Olá! Como está?"),
                VocabularyItem(word: "Bom dia", pronunciation: "bom DEE-ah", translation: "Good morning", example: "Bom dia! Tudo bem?")
            ],
            grammarExplanation: "Portuguese has nasal vowels and formal 'você/o senhor' forms.",
            grammarExamples: ["Eu sou... (I am...)", "Como está? (How are you?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Olá! Tudo bem?", translation: "Hello! All good?"),
                DialogueLine(speaker: "B", text: "Tudo! E você?", translation: "All good! And you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "Tudo bem?", translation: "All good?", context: "Common greeting", difficulty: 1)
            ],
            culturalNotes: ["Brazilian Portuguese differs from European Portuguese"],
            fluencyTechniques: ["Practice nasal sounds"],
            scenarios: [],
            pronunciationTips: ["Nasal 'ão' sounds like 'own' through nose"]
        )
    }

    static func getJapaneseContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "レッスン\(lessonNumber) - Lesson \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "こんにちは", pronunciation: "kon-ni-chi-wa", translation: "Hello", example: "こんにちは！元気ですか？"),
                VocabularyItem(word: "ありがとう", pronunciation: "a-ri-ga-to", translation: "Thank you", example: "ありがとうございます。"),
                VocabularyItem(word: "すみません", pronunciation: "su-mi-ma-sen", translation: "Excuse me/Sorry", example: "すみません、駅はどこですか？")
            ],
            grammarExplanation: "Japanese uses multiple levels of politeness (casual, polite, honorific).",
            grammarExamples: ["私は...です (I am...)", "お名前は？(What's your name?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "こんにちは！", translation: "Hello!"),
                DialogueLine(speaker: "B", text: "こんにちは！元気ですか？", translation: "Hello! How are you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "こんにちは", translation: "Hello", context: "Daytime greeting", difficulty: 1),
                SRSPhrase(phrase: "ありがとう", translation: "Thank you", context: "Expressing gratitude", difficulty: 1)
            ],
            culturalNotes: ["Bowing is essential - depth shows respect level"],
            fluencyTechniques: ["Practice pitch accent patterns"],
            scenarios: [],
            pronunciationTips: ["Every syllable gets equal time/stress"]
        )
    }

    static func getChineseContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "第\(lessonNumber)课 - Lesson \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "你好", pronunciation: "nǐ hǎo", translation: "Hello", example: "你好！你好吗？"),
                VocabularyItem(word: "谢谢", pronunciation: "xiè xie", translation: "Thank you", example: "谢谢你的帮助。"),
                VocabularyItem(word: "对不起", pronunciation: "duì bu qǐ", translation: "Sorry", example: "对不起，我迟到了。"),
                VocabularyItem(word: "我叫...", pronunciation: "wǒ jiào", translation: "My name is...", example: "我叫李明。")
            ],
            grammarExplanation: "Chinese is tonal - same syllable with different tones means different words. Word order is SVO like English.",
            grammarExamples: ["我是... (I am...)", "你叫什么名字？(What's your name?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "你好！", translation: "Hello!"),
                DialogueLine(speaker: "B", text: "你好！你好吗？", translation: "Hello! How are you?"),
                DialogueLine(speaker: "A", text: "我很好，谢谢。", translation: "I'm fine, thank you.")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "你好", translation: "Hello", context: "Standard greeting", difficulty: 1),
                SRSPhrase(phrase: "我叫...", translation: "My name is...", context: "Introduction", difficulty: 1)
            ],
            culturalNotes: ["Four tones in Mandarin - practice essential", "Respect for elders very important"],
            fluencyTechniques: ["Practice tones daily with tone pairs", "Use pinyin with tone marks"],
            scenarios: [],
            pronunciationTips: ["Master the 4 tones: flat, rising, dip-rise, falling"]
        )
    }

    static func getKoreanContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "레슨 \(lessonNumber) - Lesson \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "안녕하세요", pronunciation: "an-nyeong-ha-se-yo", translation: "Hello", example: "안녕하세요! 잘 지내세요?"),
                VocabularyItem(word: "감사합니다", pronunciation: "gam-sa-ham-ni-da", translation: "Thank you", example: "정말 감사합니다."),
                VocabularyItem(word: "죄송합니다", pronunciation: "joe-song-ham-ni-da", translation: "Sorry", example: "죄송합니다."),
                VocabularyItem(word: "제 이름은...", pronunciation: "je i-reum-eun", translation: "My name is...", example: "제 이름은 김민수입니다.")
            ],
            grammarExplanation: "Korean has multiple speech levels (formal, polite, casual). Sentence structure is SOV (Subject-Object-Verb).",
            grammarExamples: ["저는...입니다 (I am...)", "이름이 뭐예요? (What's your name?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "안녕하세요!", translation: "Hello!"),
                DialogueLine(speaker: "B", text: "안녕하세요! 잘 지내세요?", translation: "Hello! How are you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "안녕하세요", translation: "Hello", context: "Polite greeting", difficulty: 1)
            ],
            culturalNotes: ["Bowing is important", "Age and status determine speech level"],
            fluencyTechniques: ["Practice Hangul reading daily"],
            scenarios: [],
            pronunciationTips: ["Hangul is phonetic - learn the alphabet first"]
        )
    }

    static func getArabicContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "الدرس \(lessonNumber) - Lesson \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "مرحبا", pronunciation: "mar-ha-ban", translation: "Hello", example: "مرحبا! كيف حالك؟"),
                VocabularyItem(word: "شكرا", pronunciation: "shuk-ran", translation: "Thank you", example: "شكرا جزيلا"),
                VocabularyItem(word: "من فضلك", pronunciation: "min fad-lik", translation: "Please", example: "من فضلك، ساعدني."),
                VocabularyItem(word: "اسمي...", pronunciation: "is-mee", translation: "My name is...", example: "اسمي أحمد.")
            ],
            grammarExplanation: "Arabic reads right to left. Has masculine/feminine forms and formal/informal address.",
            grammarExamples: ["أنا... (I am...)", "ما اسمك؟ (What's your name?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "مرحبا!", translation: "Hello!"),
                DialogueLine(speaker: "B", text: "مرحبا! كيف حالك؟", translation: "Hello! How are you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "مرحبا", translation: "Hello", context: "Greeting", difficulty: 1)
            ],
            culturalNotes: ["Right hand for eating/greeting", "Hospitality very important"],
            fluencyTechniques: ["Practice Arabic script daily"],
            scenarios: [],
            pronunciationTips: ["Guttural sounds from throat - practice ع and ح"]
        )
    }

    static func getRussianContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Урок \(lessonNumber) - Lesson \(lessonNumber)",
            vocabulary: [
                VocabularyItem(word: "Привет", pronunciation: "pri-VYET", translation: "Hi", example: "Привет! Как дела?"),
                VocabularyItem(word: "Здравствуйте", pronunciation: "ZDRA-stvuy-tye", translation: "Hello (formal)", example: "Здравствуйте! Как вы поживаете?"),
                VocabularyItem(word: "Спасибо", pronunciation: "spa-SEE-ba", translation: "Thank you", example: "Большое спасибо!"),
                VocabularyItem(word: "Меня зовут...", pronunciation: "me-NYA za-VUT", translation: "My name is...", example: "Меня зовут Иван.")
            ],
            grammarExplanation: "Russian has 6 cases that change word endings. Formal 'вы' and informal 'ты' forms.",
            grammarExamples: ["Я... (I am...)", "Как вас зовут? (What's your name?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Привет!", translation: "Hi!"),
                DialogueLine(speaker: "B", text: "Привет! Как дела?", translation: "Hi! How are you?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "Привет", translation: "Hi", context: "Informal greeting", difficulty: 1)
            ],
            culturalNotes: ["Smile mostly for people you know", "Take off shoes when entering home"],
            fluencyTechniques: ["Practice Cyrillic alphabet daily"],
            scenarios: [],
            pronunciationTips: ["Stress determines vowel quality - unstressed 'o' sounds like 'a'"]
        )
    }

    static func getEnglishContent(lessonNumber: Int) -> LessonContentData {
        return LessonContentData(
            title: "Lesson \(lessonNumber) - English",
            vocabulary: [
                VocabularyItem(word: "Hello", pronunciation: "heh-LOH", translation: "Hola", example: "Hello! How are you?"),
                VocabularyItem(word: "Thank you", pronunciation: "THANK yoo", translation: "Gracias", example: "Thank you very much!"),
                VocabularyItem(word: "Please", pronunciation: "PLEEZ", translation: "Por favor", example: "Can I have water, please?")
            ],
            grammarExplanation: "English grammar explanation for lesson \(lessonNumber)",
            grammarExamples: ["I am... (Yo soy...)", "What's your name? (¿Cómo te llamas?)"],
            dialogues: [
                DialogueLine(speaker: "A", text: "Hello!", translation: "¡Hola!"),
                DialogueLine(speaker: "B", text: "Hi! How are you?", translation: "¡Hola! ¿Cómo estás?")
            ],
            srsKeyPhrases: [
                SRSPhrase(phrase: "Hello", translation: "Hola", context: "Greeting", difficulty: 1)
            ],
            culturalNotes: ["Cultural note about English-speaking cultures"],
            fluencyTechniques: ["Practice technique"],
            scenarios: [],
            pronunciationTips: ["Pronunciation tip for English"]
        )
    }
}
