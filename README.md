# Quiz-Performance-Dashboard-Using-R-
This code creates an interactive dashboard using Shiny to analyze quiz scores of students. It includes histograms, comparison charts, trends, and statistics.

 1️⃣ Installing & Loading Packages
install.packages(c("shiny", "dplyr", "ggplot2", "plotly"))
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
✔ Installs & loads required libraries:

Package	Functionality
shiny	Create interactive web apps
dplyr	Data manipulation
ggplot2	Data visualization
plotly	Interactive charts
 
2️⃣ Creating Sample Data
set.seed(101)

quiz_data <- data.frame(
  Student = rep(paste("Student", 1:10), each = 5),
  Quiz = rep(paste("Quiz", 1:5), times = 10),
  Score = sample(40:100, 50, replace = TRUE)
)


✔ Creates a dataset with:

10 students

5 quizzes each → total 50 rows

Random scores between 40 and 100

 3️⃣ UI (User Interface)
ui <- fluidPage(
  titlePanel("Quiz Performance Dashboard"),


✔ App title

⭐ Sidebar Layout

sidebarPanel(
  selectInput("student", "Select Student:", choices = c("All", unique(quiz_data$Student))),
  selectInput("quiz", "Select Quiz:", choices = c("All", unique(quiz_data$Quiz))),
  hr(),
  h5("Dashboard Filters")
)


✅ Two dropdown filters:

Filter by Student

Filter by Quiz

⭐ Main Panel With Tabs

tabsetPanel(
  tabPanel("Score Distribution", plotlyOutput("score_dist")),
  tabPanel("Student Comparison", plotlyOutput("student_comp")),
  tabPanel("Quiz Trend", plotlyOutput("quiz_trend")),
  tabPanel("Statistics", tableOutput("stats_table"))
)


✔ 4 Tabs:

Histogram of scores

Bar chart comparing average scores per student

Trend line of quiz performance

Statistics table of selected filters

📌 4️⃣ Server Logic
filtered_data <- reactive({
  data <- quiz_data
  if (input$student != "All") { data <- data[data$Student == input$student,] }
  if (input$quiz != "All") { data <- data[data$Quiz == input$quiz,] }
  data
})


🔹 reactive() updates data based on filter selection automatically.

📊 Output 1: Score Distribution
output$score_dist <- renderPlotly({
  p <- ggplot(filtered_data(), aes(x = Score)) +
    geom_histogram(bins = 10, fill = "#2E86C1") +
    labs(title = "Score Distribution", x = "Score", y = "Count")
  ggplotly(p)
})


✔ Histogram of quiz scores
✔ Automatically updates with filters

🧍 Output 2: Student Comparison Chart
output$student_comp <- renderPlotly({
  comp <- quiz_data %>% group_by(Student) %>% summarise(AvgScore = mean(Score))
  p <- ggplot(comp, aes(x = Student, y = AvgScore, fill = Student)) +
    geom_col() +
    labs(title = "Average Score per Student", y = "Average Score")
  ggplotly(p)
})


✔ Shows average score of each student

📈 Output 3: Quiz Trend Chart
output$quiz_trend <- renderPlotly({
  trend <- quiz_data %>% group_by(Quiz) %>% summarise(AvgScore = mean(Score))
  p <- ggplot(trend, aes(x = Quiz, y = AvgScore, group = 1)) +
    geom_line(color = "#E74C3C", size = 1.3) +
    geom_point(size = 3) +
    labs(title = "Average Score Trend by Quiz")
  ggplotly(p)
})


✔ Line graph of performance trend across quizzes

📋 Output 4: Statistics Summary Table
output$stats_table <- renderTable({
  filtered_data() %>%
    summarise(
      Max_Score = max(Score),
      Min_Score = min(Score),
      Avg_Score = round(mean(Score), 2)
    )
})


✔ Shows:

Highest score

Lowest score

Mean score
based on filters

✅ Run the Shiny App
shinyApp(ui, server)


This launches the interactive web dashboard.

🎯 Summary of Application Features
Tab	Visualization Type	Purpose
Score Distribution	Histogram	See score spread
Student Comparison	Bar Chart	Compare avg performance
Quiz Trend	Line Chart	Performance progress over quizzes
Statistics	Table	Quick stats of filtered data
