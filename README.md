# Supply-Chain
![Quality   Shipping Companies](https://github.com/user-attachments/assets/bc7e9296-94bd-4d44-8607-d6dff9c06c21)

Data Analysis Project: Supply Chain Dataset By May Gamal And DEPI TEAM Memebers (Final Project Team)
Introduction

This project analyzes a comprehensive supply chain dataset to derive insights into product type performance, customer demographics, and operational efficiency. The dataset includes various attributes such as product type, SKU, price, availability, inspection results, and more. The primary goals are to understand sales trends, customer preferences, and areas for operational improvement.
Objectives

    Evaluate Product Type Performance: Assess sales performance of different product types to identify revenue trends.
    Analyze Customer Demographics: Explore how demographic factors influence purchasing behavior and product preferences.
    Assess Operational Efficiency: Examine lead times, shipping costs, and defect rates to identify optimization opportunities.
    Visualize Key Metrics: Create visual representations to facilitate insight communication.

Steps
Step 1: Data Wrangling and Cleaning (Python)

    Data Loading: Import the dataset using Pandas and inspect the first few rows to understand the structure.

    python

import pandas as pd
df = pd.read_csv("supply_chain_data.csv")
df.head()

Initial Exploration:

    Check Dataset Shape: df.shape
    Identify Duplicates: df.duplicated().any()
    Data Type and Summary Statistics: df.info() and df.describe(include="all")
    Explore Unique Values: Examining categorical columns to understand unique entries for attributes like product type, customer demographics, and shipping carriers.

Data Cleaning:

    Rename Columns for Clarity: Simplify and standardize column names for better readability.

    python

df = df.rename(columns={'Lead times': 'Customer lead time', 'Lead time': 'Supplier Lead time'})

Outlier Detection: Generate box plots to identify outliers in numerical columns.

python

    import matplotlib.pyplot as plt
    import seaborn as sns

    for column in df.select_dtypes(include=['float64', 'int64']).columns:
        plt.figure(figsize=(5, 5))
        sns.boxplot(df[column])
        plt.title(f'Box Plot for {column}')
        plt.show()

Export Cleaned Data: Save the cleaned dataset for SQL analysis.

python

    df.to_csv('cleaned_supply_chain_data.csv')

Step 2: Data Analysis (SQL)

Using SQL queries,
![Q 3](https://github.com/user-attachments/assets/495a55f2-ca7f-4f13-8f95-1160769eb944)
 we further analyzed the cleaned dataset to answer specific questions and derive insights related to:

    Revenue and Sales: Understanding revenue distribution by product type and customer demographics.
    Sales and Quantities: Examining quantities sold by price levels and defect rates.
    Supplier and Supply Chain Performance: Assessing lead times, defect rates, and supplier efficiency.
    Costs and Quality: Analyzing manufacturing and shipping costs alongside defect rates.
    Shipping and Transportation: Evaluating shipping costs by carrier, location, and transportation modes.

Step 3: Data Visualization (Tableau)
![Revenue,Quantities, Supplier   CostsDashboard](https://github.com/user-attachments/assets/94d6b573-b7ee-494b-8882-67c891fbec5c)

The final visualizations highlight:

    Sales Metrics: Product revenue and quantity trends.
    Operational Efficiency: Lead time and defect rate distribution.
    Supplier Performance: Supplier impact on costs and defect rates.
    Customer Demographics: Purchasing trends by demographic groups.

Dashboard Formatting Guidelines
![black backround](https://github.com/user-attachments/assets/41c08e0d-c1c1-4ca5-8860-92df9421ca94)

    Font Sizes: Headers (15 pt), Body Text (9 pt), Data Labels and Tooltips (9 pt).
    Number Formatting: Currency for financials, percentages for defect rates, and commas for large numbers.
    Color Palette: Background #242f1f, Text #E8D8C0, Primary Charts #A8BDA3, Highlights #FFC107, and Accents #D68A2D, #FF4F20.

Conclusion

This project offers a structured analysis of supply chain data through Python, SQL, and Tableau. The cleaned dataset and visual insights provide a foundation for understanding product performance, customer behavior, and supply chain efficiency.
