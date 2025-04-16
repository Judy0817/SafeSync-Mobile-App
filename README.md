# SafeSync - Accident Severity Prediction & Alert System

SafeSync is a smart accident severity prediction system powered by machine learning and weather/road data analysis. It consists of a mobile app for users and a web application for admins to analyze data and take preventive measures based on predicted accident severity.


## Video Demonstration
<div align='center'>
<video src="https://github.com/user-attachments/assets/15acf94c-4e79-4bd6-aaf6-d2f73b01044b">
</div>

## Objectives
Users can use SafeSync to:
<ul>
  <li>Predict accident severity of selected route, based on weather and road conditions.</li>
  <li>Receive real-time accident severity alerts for each street by entering the street name.</li>
  <li>View interactive dashboards with graphs displaying past accident data clearly.</li>
</ul>

Authorities can use SafeSync to:
<ul>
  <li>Analyze accident trends and identify high risk areas for better infrastructure planning.</li>
  <li>Monitor accidents prone locations based on historical data and severity predictions.</li>
  <li>Improve emergency response times by prioritizing high severity accident areas.</li>
</ul>

## Used Technologies

- Languages
  <ul>
      <li>Dart - For frontend mobile application development</li>
      <li>Python - For model development</li>
      <li>Go - For backend service implementation</li>
      <li>SQL - For managing data held in PostgreSQL database</li>
    </ul>
- Tools
  <ul>
    <li>Android Studio, Visual Studio Code, Kaggle, Google Colab</li>
  </ul>
- Libraries
  <ul>
    <li>Tensorflow, Scikit Learn, Pandas, Numpy, Matplotlib, Seaborn, nltk, Keras </li>
  </ul>
- Database / Storage 
  <ul>
    <li>PostgreSQL</li>
  </ul>
- Authentication
  <ul>
    <li>Firebase Authentication</li>
  </ul>
- Dataset : https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents?select=US_Accidents_March23.csv



## Development Architecture Diagram
<div align='center'>
    <img src="https://github.com/user-attachments/assets/24b0bcf6-cfbd-4371-a5a9-66088f6c2a51" width="600" align="center">
</div>

## LSTM Model Architecture Diagram
<div align='center'>
    <img src="https://github.com/user-attachments/assets/7b4ad039-8a90-4580-b63c-b6a7ddd83538" width="600" align="center">
</div>

## Features
### 1. Login
This feature allows users and authority to create an account and log in to the system. And also have forgot password option. Once logged in, users will have access to all of the features of the system. And user can logout anytime.
<div align='center'>
  <img src="https://github.com/user-attachments/assets/54f6e334-d0e5-4745-91dd-c9c91a0bcd3b" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/374f1ed6-eaad-44df-bef0-38b1f9982b90" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/64269a31-f545-4801-87ed-91a293e389dd" width="150" align="center">
</div>

### 2. Dashboard
The SafeSync system includes an interactive dashboard that provides comprehensive accident analysis through different data visualizations. The dashboard is designed to help users and authorities better understanding of accident trends based on multiple factors. And it allows for more informed decision making by including Weather-Based, Road-Based, Time-Based, and Location-Based Dashboards etc. So users and authorities can get understand of how these factors have influenced past accident data.
<div align='center'>
  <img src="https://github.com/user-attachments/assets/424098ce-bbc2-492a-80d3-d53dbc3ae98e" width="250" align="center">
  <img src="https://github.com/user-attachments/assets/38488b32-1320-4dd0-99c8-2c3c4797a60e" width="250" align="center">
  <img src="https://github.com/user-attachments/assets/de8d1cce-199b-413c-be1a-dda738b8ebfd" width="250" align="center">
  <img src="https://github.com/user-attachments/assets/0b2b2e08-d0bc-431e-bc87-88bfdb9a232e" width="250" align="center">
  <img src="https://github.com/user-attachments/assets/877f27c7-85a3-401b-8f0a-b37f2f1f2fca" width="250" align="center">
  <img src="https://github.com/user-attachments/assets/6305585c-4c71-48b8-af8d-92150425eda4" width="250" align="center">
</div>

### 3. Route selection
The SafeSync system includes enhanced route selection capability, allowing users to choose safer travel routes depending on accident severity, real time weather and road data. Users can enter their starting location and destination, and the system will calculate the best route while indicating the severity levels along the way. Furthermore, the technology finds random spots throughout the path and provides real-time information at each one.  Users can see the following for each checkpoint:

 <ul>
    <li>Weather Conditions (ex : temperature, humidity, visibility, and wind speed)</li>
    <li> Road Features (ex : presence of speed bumps, junctions, crossings, railways)</li>
    <li>Severity Value (indicating the severity level based on real time weather data and road data)</li>
  </ul>
  This feature empowers users to make informed travel decisions by avoiding high-risk areas, ensuring a safer and more efficient journey.
  <div align='center'>
  <img src="https://github.com/user-attachments/assets/9ab90ed9-a03e-4d5f-99c5-6db0e42f6476" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/6a5947c6-10cc-44ee-bb16-510a93df43e3" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/38f36665-2fa6-47dc-b52f-3804d6fdaac8" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/df0e57a1-2a4d-4bc3-897a-05dbded7d47c" width="150" align="center">
</div>

### 4. Warning System
The system allows users to enter a street name and receive important information such as the predicted severity level, real time weather data, and road features for that street. If the severity is high, the system will display a warning to alert users of potential risks. Otherwise, it will indicate that the conditions are normal. This helps users stay informed about the safety of a specific street based on current severity, weather and road conditions.

<div align='center'>
  <img src="https://github.com/user-attachments/assets/1746c354-8a40-4151-a4da-3e18b5003a1c" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/9846494f-8f91-4113-ac66-3f16d3e5edf4" width="150" align="center">
  <img src="https://github.com/user-attachments/assets/face9a5d-b6b5-4ba3-8bac-f0460b7c6567" width="150" align="center">
</div>

Authorities also can enter a street name to access detailed information, including the predicted severity level, real time weather data, and road features for that street. This feature enables authorities to monitor and assess current conditions that may affect road safety. By analyzing the severity, weather, and road features, authorities can make informed decisions to address potential risks and improve road safety in real time.

<div align='center'>
  <img src="https://github.com/user-attachments/assets/18d3282c-9476-4377-8fed-6dd8da64898a" width="400" align="center">
  <img src="https://github.com/user-attachments/assets/16d5628d-2059-41c2-9fcc-e74f541b9781" width="400" align="center">
</div>
 
