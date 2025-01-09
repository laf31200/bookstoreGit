library(shiny)
library(RSQLite)
library(DBI)
library(ggplot2)
library(bslib)
library(httr)
library(jsonlite)
library(dotenv)
# Connexion avec les bases de données
conn <- dbConnect(SQLite(), "bookstore_test_LAN.sqlite")
connexion2 <- dbConnect(SQLite(), "bookstore3.sqlite")

# Interface utilisateur
ui <- fluidPage(
  theme = bs_theme(bootswatch = "cosmo"), # Thème Bootstrap
  titlePanel("Bookstore Management"),
  
  navbarPage(
    "Bookstore Operations",
    
    tabPanel("Operations",
      fluidRow(
        column(3,
          h3("Database Options"),
          selectInput("db_choice", "Select Database", 
                      choices = c("Database 1" = "connexion", 
                                  "Database 2" = "connexion2")),
          actionButton("refresh_db", "Refresh Database")
        ),
        column(9,
          tabsetPanel(
            tabPanel("Add a book",
              textInput("Book_Title", "Title", ""),
              textInput("Book_Author", "Author", ""),
              textInput("Book_Genre", "Genre", ""),
              numericInput("Book_Price", "Price ($)", 0),
              numericInput("Book_Stock", "Stock", 0),
              actionButton("Add_Book", "Add Book")
            ),
            tabPanel("Delete a book",
              textInput("Delete_BookID", "BookID", ""),
              actionButton("Delete_Book", "Delete")
            ),
            tabPanel("Add a customer",
              textInput("Customer_Name", "Name", ""),
              textInput("Customer_Email", "Email", ""),
              textInput("Customer_Phone", "Phone", ""),
              actionButton("Add_customer", "Add Customer")
            ),
            tabPanel("Delete a customer",
              textInput("Delete_customerID", "CustomerID", ""),
              actionButton("Delete_Customer", "Delete")
            ),
            tabPanel("Add an order",
              textInput("Order_CustomerID", "CustomerID", ""),
              textInput("Order_BookID", "BookID", ""),
              textInput("Order_Quantity", "Quantity", ""),
              textInput("Order_Date", "Date", ""),
              actionButton("Add_order", "Add Order")
            ),
            tabPanel("Add stock",
              numericInput("Orders_Stock", "BookID", 0),
              numericInput("number_ADD", "Enter Number", 0),
              actionButton("Add_Stock", "Add Stock")
            ),
            tabPanel("Delete stock",
              numericInput("Orders_Stock2", "BookID", 0),
              numericInput("number_Delete", "Enter Number", 0),
              actionButton("Delete_Stock", "Delete Stock")
            )
          )
        )
      )
    ),
    
    tabPanel("Search & History",
      fluidRow(
        column(6,
          h4("Search a book"),
          selectInput("Search_filter", "Filter by", 
                      choices = c("Id" = "ID", "Author" = "Author", "Keyword book" = "Keyword")),
          textInput("Search_query", "Enter your search", ""),
          actionButton("Search_Book", "Search"),
          tableOutput("Search_results")
        ),
        column(6,
          h4("Order History"),
          selectInput("Order_filter", "Filter by", 
                      choices = c("Customer" = "Customer", "Date" = "Date", "BookID" = "ID")),
          textInput("Order_query", "Enter your search", ""),
          actionButton("Search_history", "Show"),
          tableOutput("History_results")
        )
      )
    ),
    tabPanel("Book Summary",
      tags$style(HTML("
        #book_summary {
          white-space: pre-wrap;
          word-wrap: break-word;
          max-width: 100%;
        }
      ")),
      fluidRow(
        column(12,
          h3("Generate a Book Summary"),
          textInput("book_title", "Enter the book title:", ""),
          actionButton("generate_summary", "Generate Summary"),
          verbatimTextOutput("book_summary")
        )
      )
    ),
    tabPanel("Graphics",
        tabsetPanel(
            tabPanel("Sale of a Book",
                fluidRow(
                column(12,
                 h4("Sale of a Book"),
                 textInput("Sales_BookID", "BookID", ""),
                 actionButton("Sales_Book", "Generate Graph"),
                 plotOutput("sales_Book_Results")
                )
              )
            ),
            tabPanel("Top Best Selling Books",
                fluidRow(
                column(12,
                 h4("Top Best Selling Books"),
                 textInput("Top", "Choice Number Top", ""),
                 actionButton("top_books", "Top"),
                 plotOutput("top_books_Results")
        )
      )
    ),
    tabPanel("Sales Turnover Over Period",
      fluidRow(
        column(12,
          h4("Sales Turnover Over Period"),
          textInput("Turnover_Start", "Start Date (YYYY-MM-DD)", ""),
          textInput("Turnover_End", "End Date (YYYY-MM-DD)", ""),
          actionButton("Sales_Turnover", "Sales Turnover"),
          plotOutput("Turnover_Results")
        )
      )
    ),
    tabPanel("Stock Histogram",
     fluidRow(
        column(12,
         h3("Histogram of Book Stock"),
         actionButton("show_stock_hist", "Show Histogram"),
      plotOutput("stock_histogram")
    )
  )
)
  )
)
  )
)


# Serveur
server <- function(input, output, session) {
    
    # Choix de la base de données
    choix <- reactive({
        if (input$db_choice == "connexion") {
            conn
        } else {
            connexion2
        }
    })

    ### SECTION : Gestion des livres ###
    
    # Ajouter un livre
    observeEvent(input$Add_Book, {
        dbExecute(choix(),
                  "INSERT INTO Books(Title, Author, Genre, Price, Stock) VALUES (?,?,?,?,?)",
                  params = list(input$Book_Title, input$Book_Author, input$Book_Genre, input$Book_Price, input$Book_Stock))
        showNotification("SUCCESS: Book added!")
    })
    
    # Supprimer un livre
    observeEvent(input$Delete_Book, {
        dbExecute(choix(),
                  "DELETE FROM Books WHERE BookID = ?",
                  params = list(input$Delete_BookID))
        showNotification("SUCCESS: Book deleted!")
    })

    ### SECTION : Gestion des clients ###

    # Ajouter un client
    observeEvent(input$Add_customer, {
        dbExecute(choix(),
                  "INSERT INTO Customers (Name, Email, Phone) VALUES (?,?,?)",
                  params = list(input$Customer_Name, input$Customer_Email, input$Customer_Phone))
        showNotification("SUCCESS: Customer added!")
    })
    
    # Supprimer un client
    observeEvent(input$Delete_Customer, {
        dbExecute(choix(),
                  "DELETE FROM Customers WHERE CustomerID = ?",
                  params = list(input$Delete_CustomerID))
        showNotification("SUCCESS: Customer deleted!")
    })

    ### SECTION : Gestion des commandes ###
    
    # Ajouter une commande
    observeEvent(input$Add_order, {
        stock <- dbGetQuery(choix(),
                            "SELECT Stock FROM Books WHERE BookID = ?",
                            params = list(input$Order_BookID))
        
        if (nrow(stock) > 0 && stock$Stock[1] >= input$Order_Quantity) {
            dbExecute(choix(),
                      "INSERT INTO Orders(CustomerID, BookID, Quantity, OrderDate) VALUES (?,?,?,?)",
                      params = list(input$Order_CustomerID, input$Order_BookID, input$Order_Quantity, input$Order_Date))
            dbExecute(choix(),
                      "UPDATE Books SET Stock = Stock - ? WHERE BookID = ?",
                      params = list(input$Order_Quantity, input$Order_BookID))
            showNotification("SUCCESS: Order added and stock updated!")
        } else {
            showNotification("ERROR: Insufficient stock!")
        }
    })

    ### SECTION : Gestion du stock ###
    
    # Ajouter au stock
    observeEvent(input$Add_Stock, {
        dbExecute(choix(),
                  "UPDATE Books SET Stock = Stock + ? WHERE BookID = ?",
                  params = list(input$number_ADD, input$Orders_Stock))
        showNotification("SUCCESS: Stock added!")
    })
    
    # Retirer du stock
    observeEvent(input$Delete_Stock, {
        dbExecute(choix(),
                  "UPDATE Books SET Stock = Stock - ? WHERE BookID = ?",
                  params = list(input$number_Delete, input$Orders_Stock2))
        showNotification("SUCCESS: Stock updated!")
    })

    ### SECTION : Recherche et historique ###
    
    # Rechercher un livre
    observeEvent(input$Search_Book, {
        filtre <- NULL
        params <- NULL
        
        if (input$Search_filter == "ID") {
            filtre <- "SELECT * FROM Books WHERE BookID = ?"
            params <- list(input$Search_query)
        } else if (input$Search_filter == "Author") {
            filtre <- "SELECT * FROM Books WHERE Author LIKE ?"
            params <- list(paste0("%", input$Search_query, "%"))
        } else if (input$Search_filter == "Keyword") {
            filtre <- "SELECT * FROM Books WHERE Title LIKE ?"
            params <- list(paste0("%", input$Search_query, "%"))
        }
        
        output$Search_results <- renderTable({
            dbGetQuery(choix(), filtre, params)
        })
    })
    
    # Historique des commandes
    observeEvent(input$Search_history, {
        filtre <- NULL
        params <- NULL
        
        if (input$Order_filter == "Customer") {
            filtre <- "SELECT Title, Quantity, OrderDate AS Date FROM Orders, Books WHERE CustomerID = ? AND Orders.BookID = Books.BookID"
            params <- list(input$Order_query)
        } else if (input$Order_filter == "Author") {
            filtre <- "SELECT Title, Quantity, OrderDate  AS Date FROM Orders, Books WHERE Author LIKE ? AND Orders.BookID = Books.BookID"
            params <- list(paste0("%", input$Order_query, "%"))
        } else if (input$Order_filter == "Date") {
            filtre <- "SELECT Title, Quantity FROM Orders, Books WHERE OrderDate LIKE ? AND Orders.BookID = Books.BookID"
            params <- list(paste0("%", input$Order_query, "%"))
        } else if (input$Order_filter == "ID") {
            filtre <- "SELECT Quantity, OrderDate AS Date FROM Orders WHERE BookID = ? "
            params <- list(input$Order_query)
        }
        
        output$History_results <- renderTable({
            dbGetQuery(choix(), filtre, params)
        })
    })

    ### SECTION : Graphiques ###
    
    # Graphique des ventes d'un livre
    observeEvent(input$Sales_Book, {
        Sales_Book_Data <- dbGetQuery(choix(),
                                      "SELECT OrderDate, Quantity FROM Orders WHERE BookID = ? ORDER BY OrderDate",
                                      params = list(input$Sales_BookID))
        
        output$sales_Book_Results <- renderPlot({
            ggplot(Sales_Book_Data, aes(x = OrderDate, y = Quantity , scale_linewidth() , group = 1 )) +
                geom_point(color = "red") +
                geom_line(color = "blue") +
                theme_minimal() +
                labs(title = paste("Sales of BookID:", input$Sales_BookID), x = "Date", y = "Quantity Sold")
        })
    })
    
    # Graphique des livres les plus vendus
    observeEvent(input$top_books, {
        Top_Sales_Data <- dbGetQuery(choix(),
                                     "SELECT Title, SUM(Quantity) AS Total_Quantity FROM Orders, Books
                                      WHERE Books.BookID = Orders.BookID
                                      GROUP BY Orders.BookID
                                      ORDER BY Total_Quantity DESC
                                      LIMIT ?",
                                     params = list(input$Top))
        
        output$top_books_Results <- renderPlot({
            ggplot(Top_Sales_Data, aes(x = reorder(Title, Total_Quantity), y = Total_Quantity, fill = Title)) +
                geom_bar(stat = "identity") +
                geom_text(aes(label = Total_Quantity), hjust = -0.2, size = 5, color = "black") +
                theme_minimal() +
                labs(title = "Top Selling Books", x = "Title", y = "Sales")
        })
    })
    
    # Graphique du chiffre d'affaires sur une période donnée
    observeEvent(input$Sales_Turnover, {
        Turnover_data <- dbGetQuery(choix(),
                                    "SELECT OrderDate, SUM(Quantity * Price) AS Turnover FROM Orders, Books
                                     WHERE Books.BookID = Orders.BookID AND OrderDate BETWEEN ? AND ?
                                     GROUP BY OrderDate
                                     ORDER BY OrderDate",
                                    params = list(input$Turnover_Start, input$Turnover_End))
        
        output$Turnover_Results <- renderPlot({
            ggplot(Turnover_data, aes(x = OrderDate, y = Turnover ,scale_linewidth() , group = 1)) +
                geom_point(color = "red") +
                geom_line()+
                theme_minimal() +
                labs(title = paste("Turnover:", sum(Turnover_data$Turnover)), x = "Date", y = "Turnover")
        })
    })

    observeEvent(input$show_stock_hist, {
  # Récupérer les données des stocks
  stock_data <- dbGetQuery(choix(), "SELECT Title, Stock FROM Books")
  
  # Afficher l'histogramme des stocks
  output$stock_histogram <- renderPlot({
      ggplot(stock_data, aes(x = Stock)) +
        geom_histogram(binwidth = 5, fill = "blue", color = "black") +
        theme_minimal() +
        labs(
          title = "Histogram of Book Stocks",
          x = "Stock Quantity",
          y = "Number of Books"
        )    
  })
})

    ### SECTION GENERATE ###
    # Résumé de Livre avec BART-Large-CNN
observeEvent(input$generate_summary, {
  # Vérification : L'utilisateur a-t-il saisi un titre ?
  if (nchar(input$book_title) == 0) {
    output$book_summary <- renderText("Please enter a book title.")
  } else {
    # Préparation de la requête API avec le modèle BART-Large-CNN
    query <- paste("Summarize the book", input$book_title)
    api_url <- "https://api-inference.huggingface.co/models/facebook/bart-large-cnn"
    headers <- c(
      `Authorization` = "Bearer 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", 
      `Content-Type` = "application/json"
    )
    data <- toJSON(list(inputs = query), auto_unbox = TRUE)
    
    # Appel à l'API
    response <- POST(api_url, add_headers(.headers = headers), body = data, encode = "json")
    
    # Vérification et affichage du résultat
    if (http_status(response)$category == "Success") {
      result <- fromJSON(content(response, "text", encoding = "UTF-8")) 
      print(result$summary_text)
      output$book_summary <- renderText(result$summary_text)
    } else {
      output$book_summary <- renderText("Error: Unable to generate a summary. Please try again.")
    }
  }
})
}

shinyApp(ui, server)
