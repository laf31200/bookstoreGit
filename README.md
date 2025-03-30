
sql queries are in setup.sql

Bookstore Management Application



Features

1. Operations Tab
This tab allows for basic database operations, including:
Add a Book: Add new books to the database by providing title, author, genre, price, and stock.
Delete a Book: Remove a book from the database using its BookID.
Add a Customer: Register a new customer with name, email, and phone number.
Delete a Customer: Remove a customer from the database using their CustomerID.
Add an Order: Create a new order by specifying CustomerID, BookID, quantity, and date.
Stock Management:
Add Stock: Increase the stock of a book.
Delete Stock: Decrease the stock of a book.
2. Search & History Tab
This tab allows users to:

Search for Books: Search for books based on BookID, author name, or keywords in the title.
View Order History: Filter order history by customer, date, or book ID.
3. Book Summary Tab
Use the Hugging Face API to generate a summary of a specified book.
Enter the book title and receive a concise summary generated by the facebook/bart-large-cnn model.
4. Graphics Tab
This tab provides graphical insights into bookstore data:

Sales of a Book: View a line graph of a book’s sales over time.
Top Best Selling Books: Display a bar chart of the top-selling books.
Sales Turnover Over Period: View a graph of sales turnover within a specified date range.
Stock Histogram: Display a histogram of book stock quantities to visualize stock distribution.
Technologies Used

R Shiny: For building the web application.
SQLite: For managing the bookstore database.
ggplot2: For generating plots and visualizations.
bslib: For applying modern Bootstrap themes.
Hugging Face API: To generate book summaries using the facebook/bart-large-cnn model.
httr and jsonlite: For making API requests and parsing responses.

Getting Started

Prerequisites
Ensure the following are installed on your system:

R (version 4.0 or later)
Required R packages:
install.packages(c("shiny", "RSQLite", "DBI", "ggplot2", "bslib", "httr", "jsonlite", "dotenv"))
SQLite installed on your system.

Database Setup
Place your SQLite database files (bookstore_testLAN.sqlite and bookstore3.sqlite) in the root directory of the project.
Ensure the database contains the following tables:
Books: BookID, Title, Author, Genre, Price, Stock
Customers: CustomerID, Name, Email, Phone
Orders: OrderID, CustomerID, BookID, Quantity, OrderDate
Running the Application
Open the R script in RStudio or any R IDE.
Run the following command to launch the app:
shinyApp(ui, server)


How to Use the Features

1. Operations Tab
Select the database to work with using the dropdown menu.
Perform operations for books and customers by filling out the respective fields and clicking the corresponding buttons.
2. Search & History Tab
Search a Book: Choose a filter (ID, Author, or Keyword), enter the search query, and click "Search."
Order History: Choose a filter (Customer, Date, or BookID), enter the search query, and click "Show."
3. Book Summary Tab
Enter the title of a book in the input box.
Click Generate Summary to display summary of the book using AI.
4. Graphics Tab
Sale of a Book: Enter a BookID and click "Generate Graph" to view sales over time.
Top Best Selling Books: Enter the number of top books to display and click "Top."
Sales Turnover Over Period: Enter the start and end dates and click "Sales Turnover."
Stock Histogram: Click "Show Histogram" to display the distribution of stock levels.
Key Notes

Error Handling: The app notifies users when errors occur, such as insufficient stock or invalid inputs.
Customizable: Update the database connection or Hugging Face API key to adapt the app for your needs.
