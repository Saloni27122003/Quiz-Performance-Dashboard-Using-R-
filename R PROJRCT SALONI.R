install.packages(c("shiny", "dplyr", "ggplot2", "plotly"))


library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

# ---- Sample Data ----
set.seed(101)
quiz_data <- data.frame(
  Student = rep(paste("Student", 1:10), each = 5),
  Quiz = rep(paste("Quiz", 1:5), times = 10),
  Score = sample(40:100, 50, replace = TRUE)
)

# ---- UI ----
ui <- fluidPage(
  titlePanel("Quiz Performance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("student", "Select Student:",
                  choices = c("All", unique(quiz_data$Student))),
      selectInput("quiz", "Select Quiz:",
                  choices = c("All", unique(quiz_data$Quiz))),
      hr(),
      h5("Dashboard Filters")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Score Distribution", plotlyOutput("score_dist")),
        tabPanel("Student Comparison", plotlyOutput("student_comp")),
        tabPanel("Quiz Trend", plotlyOutput("quiz_trend")),
        tabPanel("Statistics", tableOutput("stats_table"))
      )
    )
  )
)

# ---- SERVER ----
server <- function(input, output) {
  
  # Filter data reactively
  filtered_data <- reactive({
    data <- quiz_data
    if (input$student != "All") {
      data <- data[data$Student == input$student,]
    }
    if (input$quiz != "All") {
      data <- data[data$Quiz == input$quiz,]
    }
    data
  })
  
  # Score Distribution
  output$score_dist <- renderPlotly({
    p <- ggplot(filtered_data(), aes(x = Score)) +
      geom_histogram(bins = 10, fill = "#2E86C1") +
      labs(title = "Score Distribution", x = "Score", y = "Count")
    ggplotly(p)
  })
  
  # Student Comparison
  output$student_comp <- renderPlotly({
    comp <- quiz_data %>%
      group_by(Student) %>%
      summarise(AvgScore = mean(Score))
    
    p <- ggplot(comp, aes(x = Student, y = AvgScore, fill = Student)) +
      geom_col() +
      labs(title = "Average Score per Student", y = "Average Score")
    ggplotly(p)
  })
  
  # Quiz Trend Line Chart
  output$quiz_trend <- renderPlotly({
    trend <- quiz_data %>%
      group_by(Quiz) %>%
      summarise(AvgScore = mean(Score))
    
    p <- ggplot(trend, aes(x = Quiz, y = AvgScore, group = 1)) +
      geom_line(color = "#E74C3C", size = 1.3) +
      geom_point(size = 3) +
      labs(title = "Average Score Trend by Quiz")
    ggplotly(p)
  })
  
  # Statistics Table
  output$stats_table <- renderTable({
    filtered_data() %>%
      summarise(
        Max_Score = max(Score),
        Min_Score = min(Score),
        Avg_Score = round(mean(Score), 2)
      )
  })
}

shinyApp(ui, server)
