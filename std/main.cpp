#include <SFML/Graphics.hpp>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <map>
#include <vector>
#include <functional>
#include <optional>

using namespace std;

// ==========================================
//           CONSTANTS & THEME
// ==========================================
const unsigned int WINDOW_WIDTH = 1200;
const unsigned int WINDOW_HEIGHT = 800;
const sf::Color BG_COLOR(30, 30, 35);
const sf::Color ACCENT_COLOR(0, 120, 215);
const sf::Color HOVER_COLOR(0, 140, 240);
const sf::Color TEXT_COLOR(240, 240, 240);
const sf::Color ERROR_COLOR(220, 50, 50);
const sf::Color SUCCESS_COLOR(50, 200, 100);
const sf::Color TABLE_HEADER_COLOR(60, 60, 65);

sf::Font globalFont;

// ==========================================
//        CORE LOGIC (Data Classes)
// ==========================================
class Subject {
public:
    string subjectName;
    string marksStatus;
    Subject* next;
    Subject(string name, string status) : subjectName(name), marksStatus(status), next(nullptr) {}
};

class Student {
public:
    string rollNo, name, className, category;
    Subject* subjectHead;
    Student* next;

    Student(string r, string n, string c, string cat) {
        rollNo = r; name = n; className = c; category = cat;
        subjectHead = nullptr; next = nullptr;
    }

    void addSubject(string name, string status) {
        Subject* newSub = new Subject(name, status);
        if (!subjectHead) subjectHead = newSub;
        else {
            Subject* temp = subjectHead;
            while (temp->next) temp = temp->next;
            temp->next = newSub;
        }
    }
    ~Student() {
        Subject* curr = subjectHead;
        while(curr) { Subject* n = curr->next; delete curr; curr = n; }
    }
};

class StudentManager {
public:
    Student* head;
    StudentManager() : head(nullptr) {}

    void addStudent(string r, string n, string c, string cat) {
        if(findStudent(r)) return; 
        Student* newS = new Student(r, n, c, cat);
        newS->addSubject("English", "0");
        newS->addSubject("Math", "0");
        if (!head) head = newS;
        else {
            Student* temp = head;
            while (temp->next) temp = temp->next;
            temp->next = newS;
        }
    }

    Student* findStudent(string roll) {
        Student* curr = head;
        while (curr) {
            if (curr->rollNo == roll) return curr;
            curr = curr->next;
        }
        return nullptr;
    }

    bool deleteStudent(string roll) {
        if (!head) return false;

        // Case 1: Head is the student to delete
        if (head->rollNo == roll) {
            Student* toDelete = head;
            head = head->next;
            delete toDelete;
            return true;
        }

        // Case 2: Search in the list
        Student* current = head;
        while (current->next != nullptr) {
            if (current->next->rollNo == roll) {
                Student* toDelete = current->next;
                current->next = current->next->next;
                delete toDelete;
                return true;
            }
            current = current->next;
        }
        return false;
    }
};

// ==========================================
//          UI FRAMEWORK (SFML 3.0)
// ==========================================

class Button {
public:
    sf::RectangleShape shape;
    sf::Text text; 
    bool isHovered = false;
    string id; // To identify button clicks (e.g. which class)

    Button(string btnText, sf::Vector2f size, sf::Vector2f pos, unsigned int fontSize = 20, string btnId = "") 
        : text(globalFont), id(btnId) 
    {
        shape.setSize(size);
        shape.setPosition(pos);
        shape.setFillColor(ACCENT_COLOR);
        shape.setOutlineThickness(1);
        shape.setOutlineColor(sf::Color::White);

        text.setString(btnText);
        text.setCharacterSize(fontSize);
        text.setFillColor(sf::Color::White);
        
        sf::FloatRect textRect = text.getLocalBounds();
        text.setOrigin({textRect.position.x + textRect.size.x/2.0f, textRect.position.y + textRect.size.y/2.0f});
        text.setPosition({pos.x + size.x/2.0f, pos.y + size.y/2.0f});
    }

    bool update(sf::Vector2i mousePos, bool isClicked) {
        isHovered = shape.getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePos));
        if (isHovered) {
            shape.setFillColor(HOVER_COLOR);
            if (isClicked) return true;
        } else {
            shape.setFillColor(ACCENT_COLOR);
        }
        return false;
    }

    void draw(sf::RenderWindow& window) {
        window.draw(shape);
        window.draw(text);
    }
};

class InputBox {
public:
    sf::RectangleShape shape;
    sf::Text textDisplay;
    sf::Text labelText;
    string value;
    bool isActive = false;
    int limit;

    InputBox(string label, sf::Vector2f pos, float width, int charLimit = 50) 
        : textDisplay(globalFont), labelText(globalFont)
    {
        limit = charLimit;
        
        labelText.setString(label);
        labelText.setCharacterSize(18);
        labelText.setFillColor(TEXT_COLOR);
        labelText.setPosition(pos);

        shape.setPosition({pos.x, pos.y + 30});
        shape.setSize({width, 35});
        shape.setFillColor(sf::Color(60, 60, 65));
        shape.setOutlineThickness(1);
        shape.setOutlineColor(sf::Color(100, 100, 100));

        textDisplay.setCharacterSize(18);
        textDisplay.setFillColor(sf::Color::White);
        textDisplay.setPosition({pos.x + 5, pos.y + 35});
    }

    void handleInput(uint32_t unicode) {
        if (!isActive) return;
        if (unicode == 8) { // Backspace
            if (!value.empty()) value.pop_back();
        } else if (unicode < 128 && value.length() < limit) {
            value += static_cast<char>(unicode);
        }
        textDisplay.setString(value + "|");
    }

    void update(sf::Vector2i mousePos, bool click) {
        if (click) {
            isActive = shape.getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePos));
            if (isActive) {
                shape.setOutlineColor(ACCENT_COLOR);
                textDisplay.setString(value + "|");
            } else {
                shape.setOutlineColor(sf::Color(100, 100, 100));
                textDisplay.setString(value);
            }
        }
    }

    void draw(sf::RenderWindow& window) {
        window.draw(labelText);
        window.draw(shape);
        window.draw(textDisplay);
    }

    void clear() {
        value = "";
        textDisplay.setString("");
    }
};

// ==========================================
//          APPLICATION STATE
// ==========================================
enum AppState { MENU, ADD_STUDENT, VIEW_CLASSES, VIEW_CLASS_DETAILS, SEARCH, DELETE_STUDENT };

class App {
private:
    sf::RenderWindow window;
    StudentManager manager;
    AppState currentState;
    
    // Containers
    vector<Button*> menuButtons;
    vector<Button*> navButtons;
    vector<Button*> classButtons; // For Class 1-12
    
    // Add Student Form
    InputBox* inRoll;
    InputBox* inName;
    InputBox* inClass;
    InputBox* inCat;
    Button* btnSubmitAdd;

    // Search/Delete
    InputBox* inAction; // Reused for Search and Delete
    Button* btnAction;  // Reused button
    
    string notification = "";
    sf::Clock notificationTimer;

    string selectedClass = ""; // Stores which class we are viewing details for

public:
    App() {
        window.create(sf::VideoMode({WINDOW_WIDTH, WINDOW_HEIGHT}), "Student System Pro");
        window.setFramerateLimit(60);
        currentState = MENU;

        if (!globalFont.openFromFile("arial.ttf")) {
             cout << "ERROR: arial.ttf not found!" << endl;
        }
        
        // Add dummy data for testing
        manager.addStudent("101", "Ali Khan", "10", "CS");
        manager.addStudent("102", "Sara Ahmed", "10", "Bio");
        manager.addStudent("103", "John Doe", "9", "CS");
        manager.addStudent("104", "Mike Ross", "12", "Pre-Eng");

        setupUI();
    }

    void setupUI() {
        float centerX = WINDOW_WIDTH / 2.0f - 150;
        float startY = 150;
        
        // Main Menu
        menuButtons.push_back(new Button("Add Student", {300, 50}, {centerX, startY}));
        menuButtons.push_back(new Button("View All Classes", {300, 50}, {centerX, startY + 70}));
        menuButtons.push_back(new Button("Search Student", {300, 50}, {centerX, startY + 140}));
        menuButtons.push_back(new Button("Delete Student", {300, 50}, {centerX, startY + 210}));
        menuButtons.push_back(new Button("Exit", {300, 50}, {centerX, startY + 280}));

        // Nav
        navButtons.push_back(new Button("Back", {100, 40}, {20, 20}, 16));

        // Add Student Form
        float formX = WINDOW_WIDTH / 2.0f - 200;
        inRoll = new InputBox("Roll Number:", {formX, 120}, 400);
        inName = new InputBox("Full Name:", {formX, 200}, 400);
        inClass = new InputBox("Class (1-12):", {formX, 280}, 400);
        inCat = new InputBox("Category:", {formX, 360}, 400);
        btnSubmitAdd = new Button("Save Student", {200, 50}, {WINDOW_WIDTH / 2.0f - 100, 460});

        // Search/Delete Input
        inAction = new InputBox("Enter Roll No:", {WINDOW_WIDTH/2.0f - 200, 200}, 300);
        btnAction = new Button("Action", {100, 35}, {WINDOW_WIDTH/2.0f + 120, 230}, 16);

        // Create Class Grid Buttons (Class 1 to 12)
        float gridStartX = 200;
        float gridStartY = 150;
        float gapX = 220;
        float gapY = 80;
        
        for(int i=1; i<=12; i++) {
            int row = (i-1) / 4; 
            int col = (i-1) % 4;
            
            sf::Vector2f pos(gridStartX + (col * gapX), gridStartY + (row * gapY));
            classButtons.push_back(new Button("Class " + to_string(i), {180, 50}, pos, 20, to_string(i)));
        }
    }

    void showNotify(string msg, bool isError = false) {
        notification = msg;
        notificationTimer.restart();
    }

    void run() {
        while (window.isOpen()) {
            processEvents();
            render();
        }
    }

    void processEvents() {
        while (const auto event = window.pollEvent()) {
            if (event->is<sf::Event::Closed>()) {
                window.close();
            }

            if (const auto* textEvent = event->getIf<sf::Event::TextEntered>()) {
                if (currentState == ADD_STUDENT) {
                    inRoll->handleInput(textEvent->unicode);
                    inName->handleInput(textEvent->unicode);
                    inClass->handleInput(textEvent->unicode);
                    inCat->handleInput(textEvent->unicode);
                }
                if (currentState == SEARCH || currentState == DELETE_STUDENT) {
                    inAction->handleInput(textEvent->unicode);
                }
            }
            
            if (const auto* mouseEvent = event->getIf<sf::Event::MouseButtonPressed>()) {
                if (mouseEvent->button == sf::Mouse::Button::Left) {
                    handleClicks();
                }
            }
        }
    }

    void handleClicks() {
        sf::Vector2i mousePos = sf::Mouse::getPosition(window);
        bool click = true;

        if (currentState == MENU) {
            if (menuButtons[0]->update(mousePos, click)) currentState = ADD_STUDENT;
            if (menuButtons[1]->update(mousePos, click)) currentState = VIEW_CLASSES;
            if (menuButtons[2]->update(mousePos, click)) { currentState = SEARCH; inAction->clear(); }
            if (menuButtons[3]->update(mousePos, click)) { currentState = DELETE_STUDENT; inAction->clear(); }
            if (menuButtons[4]->update(mousePos, click)) window.close();
        } 
        else {
            // Global Back Button Logic
            if (navButtons[0]->update(mousePos, click)) {
                if (currentState == VIEW_CLASS_DETAILS) {
                    currentState = VIEW_CLASSES; // Back to grid
                } else {
                    currentState = MENU; // Back to main
                }
                notification = "";
            }

            if (currentState == ADD_STUDENT) {
                inRoll->update(mousePos, click);
                inName->update(mousePos, click);
                inClass->update(mousePos, click);
                inCat->update(mousePos, click);
                
                if (btnSubmitAdd->update(mousePos, click)) {
                    if (inRoll->value.empty()) showNotify("Error: Missing Data", true);
                    else if (manager.findStudent(inRoll->value)) showNotify("Error: Exists!", true);
                    else {
                        manager.addStudent(inRoll->value, inName->value, inClass->value, inCat->value);
                        showNotify("Success: Student Added!");
                        inRoll->clear(); inName->clear(); inClass->clear(); inCat->clear();
                    }
                }
            }
            else if (currentState == VIEW_CLASSES) {
                // Check class grid clicks
                for(auto btn : classButtons) {
                    if(btn->update(mousePos, click)) {
                        selectedClass = btn->id; // Store "1", "2", "10" etc.
                        currentState = VIEW_CLASS_DETAILS;
                    }
                }
            }
            else if (currentState == SEARCH) {
                inAction->update(mousePos, click);
                if (btnAction->update(mousePos, click)) {
                    Student* s = manager.findStudent(inAction->value);
                    if(s) showNotify("Found: " + s->name + " (Class " + s->className + ")");
                    else showNotify("Student Not Found", true);
                }
            }
            else if (currentState == DELETE_STUDENT) {
                inAction->update(mousePos, click);
                if (btnAction->update(mousePos, click)) {
                    if(manager.deleteStudent(inAction->value)) {
                        showNotify("Success: Student Deleted!");
                        inAction->clear();
                    } else {
                        showNotify("Error: Student Not Found", true);
                    }
                }
            }
        }
    }

    void drawHeader(string title) {
        sf::Text t(globalFont, title, 32);
        t.setFillColor(sf::Color::White);
        sf::FloatRect bounds = t.getGlobalBounds();
        t.setPosition({WINDOW_WIDTH/2.0f - bounds.size.x/2.0f, 30.0f});
        window.draw(t);
    }

    void render() {
        window.clear(BG_COLOR);

        // Hover logic updates
        sf::Vector2i mPos = sf::Mouse::getPosition(window);
        if(currentState == MENU) for(auto b : menuButtons) b->update(mPos, false);
        else navButtons[0]->update(mPos, false);
        
        if(currentState == ADD_STUDENT) btnSubmitAdd->update(mPos, false);
        if(currentState == VIEW_CLASSES) for(auto b : classButtons) b->update(mPos, false);
        if(currentState == SEARCH || currentState == DELETE_STUDENT) btnAction->update(mPos, false);

        // Rendering Logic
        if (currentState == MENU) {
            drawHeader("Student Management System");
            for (auto b : menuButtons) b->draw(window);
        }
        else if (currentState == ADD_STUDENT) {
            navButtons[0]->draw(window);
            drawHeader("Add New Student");
            inRoll->draw(window);
            inName->draw(window);
            inClass->draw(window);
            inCat->draw(window);
            btnSubmitAdd->draw(window);
        }
        else if (currentState == VIEW_CLASSES) {
            navButtons[0]->draw(window);
            drawHeader("Select Class to View");
            for(auto b : classButtons) b->draw(window);
        }
        else if (currentState == VIEW_CLASS_DETAILS) {
            navButtons[0]->draw(window);
            drawHeader("Class " + selectedClass + " Students");

            // --- TABLE RENDER ---
            float startY = 120;
            float col1X = 200; // Roll No
            float col2X = 500; // Name
            float col3X = 900; // Category

            // Draw Table Header Background
            sf::RectangleShape headerBg({WINDOW_WIDTH - 200.f, 40.f});
            headerBg.setPosition({100.f, startY});
            headerBg.setFillColor(TABLE_HEADER_COLOR);
            window.draw(headerBg);

            // Draw Headers
            sf::Text h1(globalFont, "Reg No", 20); h1.setPosition({col1X, startY+7}); window.draw(h1);
            sf::Text h2(globalFont, "Student Name", 20); h2.setPosition({col2X, startY+7}); window.draw(h2);
            sf::Text h3(globalFont, "Category", 20); h3.setPosition({col3X, startY+7}); window.draw(h3);

            // Draw Rows
            float currentY = startY + 50;
            Student* curr = manager.head;
            bool foundAny = false;

            while(curr) {
                if(curr->className == selectedClass) {
                    foundAny = true;
                    // Draw Row Data
                    sf::Text t1(globalFont, curr->rollNo, 18); t1.setPosition({col1X, currentY}); window.draw(t1);
                    sf::Text t2(globalFont, curr->name, 18); t2.setPosition({col2X, currentY}); window.draw(t2);
                    sf::Text t3(globalFont, curr->category, 18); t3.setPosition({col3X, currentY}); window.draw(t3);
                    
                    // Draw separator line
                    sf::RectangleShape line({WINDOW_WIDTH - 200.f, 1.f});
                    line.setPosition({100.f, currentY + 25});
                    line.setFillColor(sf::Color(80, 80, 80));
                    window.draw(line);

                    currentY += 35;
                }
                curr = curr->next;
            }

            if(!foundAny) {
                sf::Text msg(globalFont, "No students found in Class " + selectedClass, 20);
                msg.setFillColor(sf::Color(150, 150, 150));
                sf::FloatRect b = msg.getGlobalBounds();
                msg.setPosition({WINDOW_WIDTH/2.0f - b.size.x/2.0f, 300.0f});
                window.draw(msg);
            }
        }
        else if (currentState == SEARCH || currentState == DELETE_STUDENT) {
            navButtons[0]->draw(window);
            string title = (currentState == SEARCH) ? "Search Student" : "Delete Student";
            string btnText = (currentState == SEARCH) ? "Search" : "Delete";
            
            drawHeader(title);
            inAction->draw(window);
            
            // Hacky: Update button text based on mode
            btnAction->text.setString(btnText); 
            btnAction->draw(window);
        }

        // Notifications
        if (!notification.empty()) {
            if (notificationTimer.getElapsedTime().asSeconds() > 3) notification = "";
            sf::Text t(globalFont, notification, 20);
            t.setFillColor(notification.find("Error") != string::npos ? ERROR_COLOR : SUCCESS_COLOR);
            sf::FloatRect bounds = t.getGlobalBounds();
            t.setPosition({WINDOW_WIDTH/2.0f - bounds.size.x/2.0f, WINDOW_HEIGHT - 50.0f});
            window.draw(t);
        }

        window.display();
    }
};

int main() {
    App app;
    app.run();
    return 0;
}