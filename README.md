# Data-Projects-
1. Project Title / Headline
Apex Velo & Co: Performance Intelligence & Sales Operations Dashboard
A sophisticated business intelligence tool engineered to synthesize global sales data, providing a dual-layered perspective from high-level commercial trends to granular transactional auditing.

2. Short Description / Purpose
The Apex Velo & Co Dashboard is a professional Power BI reporting solution designed to monitor and analyze the performance of a global cycling enterprise. It serves to bridge the gap between volume-driven growth and margin sustainability, providing commerce and finance stakeholders with the visibility needed to optimize pricing strategies and regional inventory allocation.

3. Tech Stack
The dashboard was built using the following tools and technologies:

📊 Power BI Desktop – Used as the primary visualization engine to create an interactive two-page analytical report.

🗄️ MySQL / SQL – Utilized for the foundational data engineering layer, including complex joins and data cleaning of the AdventureWorks-derived datasets.

🧠 DAX (Data Analysis Expressions) – Implemented to create dynamic KPIs such as Total Sales, Average Price, and Volume variances.

📝 Data Modeling – Established a relational schema to enable seamless cross-filtering between product categories, time dimensions, and geographic regions.

📂 File Formats – .pbix for dashboard architecture and .sql for backend data transformations.
                  ![Overview page](https://github.com/user-attachments/assets/afb934dc-ba09-4cd6-80a5-72ec10550819)

4. Data Source
Source: AdventureWorks Database & Apex Velo Sales Records.
The data consists of thousands of rows of transactional records covering a diverse product catalog of bikes, accessories, and clothing. It includes detailed dimensions for geographic regions (North America, Europe, Pacific), product sub-categories, and historical sales timestamps.

5. Features / Highlights
Business Problem
In a competitive commerce environment, maintaining profitability while scaling volume is a significant challenge. Analysts often struggle to identify whether revenue growth is organic or driven by margin-eroding discounts, especially when dealing with high-ticket items like premium mountain bikes.

Goal of the Dashboard
To deliver a strategic tool that:

Monitors the relationship between sales volume and average unit price.

Identifies regional revenue strongholds and underperforming product categories.

Provides a drill-down "Details" view for auditing high-value transactions.

Walkthrough of Key Visuals

Executive KPIs (Top Header): Real-time tracking of Total Sales ($69.22M), Avg Price ($654.52), and Products Sold (50K), featuring color-coded variance indicators.

Geographic Distribution (Map): Visualizes global sales concentration, highlighting the Northwest and Southwest regions as primary revenue drivers.

Sales vs. Max Point (Line Chart): Tracks temporal volatility, identifying massive revenue spikes (e.g., $8.1M) and seasonal lulls.

Category Mix (Pie Charts): Illustrates that Bikes drive 85.94% of revenue, while Accessories and Clothing dominate transaction volume.

Transactional Audit (Details Page): A granular table allowing users to track specific ProductIDs and high-value single sales exceeding $80,000.

Business Impact & Insights

Margin Protection: Identifies a 14.88% drop in average price, prompting a review of discounting strategies.

Inventory Optimization: Highlights that Black and Red variants dominate nearly 40% of the market.

Strategic Upselling: Reveals a massive opportunity to improve "attachment rates" for accessories among the high-value bike-buying demographic.
