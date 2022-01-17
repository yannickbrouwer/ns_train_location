/*
With this sketch you can request train location data from the Dutch Railways (NS).

To get this to work, add the HTTP Requests Library by going to:
Sketch -> Import Library -> Add Library -> Find HTTP Requests for Processing by Rune Madsen and Daniel Shiffman and click Install

Request a free API key by registering in the API store of NS: https://apiportal.ns.nl/
This code uses the Virtual Train API. Add your key in the code below.

Structure:
links, payload, treinen

"treinNummer": 32230,
      "ritId": "32230",
      "lat": 51.6389,
      "lng": 5.945404,
      "snelheid": 65.64729,
      "richting": 312.0,
      "horizontaleNauwkeurigheid": 2333.3333,
      "type": "ARR",
      "bron": "KV6"
      
*/

import http.requests.*;
JSONObject json;
JSONObject payLoad;
JSONArray treinPosities;
JSONObject trein;

import java.io.BufferedWriter;
import java.io.FileWriter;

String outFilename = "output.txt";

//Interval in seconds when data is saved. Default is every 10 seconds.
int interval = 10;
int count = 1;
int prevCount = 21;
int errorCount = 0;

void setup(){
  size(100,100);
outFilename = year() +"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_trains.txt";
 }
 
 void draw(){
//Save data every interval. 
   count = second();
   if (count%interval==0){
    if (count!=prevCount){
      loadData();
    }
   }
   
   prevCount = count;

//An API can sometimes throw an error, if it's a single one it will be ignored but if we get 6 of them in a row it might be better to stop.
   if (errorCount>6){
   println("Too many errors");
   exit();
   }
 }
 
 void loadData() {
  
   try{
  GetRequest get = new GetRequest("https://gateway.apiportal.ns.nl/virtual-train-api/api/vehicle");
   // Fill your API key in the line below between double quotes like:  get.addHeader("Ocp-Apim-Subscription-Key", "f1894d0c"); 
get.addHeader("Ocp-Apim-Subscription-Key", "YOUR_API_KEY_HERE"); 
  get.send();

 json = parseJSONObject(get.getContent());
 println(json);
 payLoad = json.getJSONObject("payload");
 treinPosities = payLoad.getJSONArray("treinen");
 
for (int i = 0; i < treinPosities.size() ; i++) {
trein = treinPosities.getJSONObject(i);

int trainNumber = trein.getInt("treinNummer");
float lat = trein.getFloat("lat");
float lon = trein.getFloat("lng");

errorCount = 0;
appendTextToFile(outFilename, year() +"-"+nf(month(),2)+"-"+nf(day(),2)+" "+nf(hour(),2)+ ":" +nf(minute(),2) + ":" +nf(second(),2) + "," +lat+"," + lon + "," + trainNumber);

  }
   }
   catch (Exception E){
     errorCount++;
     System.out.println(E);
     appendTextToFile(outFilename,"error");
   }  
 }
 
 // Code to add data to a textfile. 
 // Original code from https://stackoverflow.com/questions/17010222/how-do-i-append-text-to-a-csv-txt-file-in-processing
 
 void appendTextToFile(String filename, String text){
  File f = new File(dataPath(filename));
  if(!f.exists()){
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e){
      e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f){
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
}    
