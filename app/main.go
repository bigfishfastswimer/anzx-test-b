package main

import (
	"net/http"
  "fmt"
  "encoding/json"
)
//Initializing global variables for GitTag and GitHash which later can be retrive from cicd
var GitTag = "v0.0.1"
var GitHash string
// Initializing struct for ReleaseInfo and Resbuilder which will be encoded for api response 
type (
	ReleaseInfo struct {
		Version string `json: "version"`
		CommitId string `json: "lastcommitsha"`
		Description string `json: "description"`
	}
)
type (
	ResBuilder struct {
		Content []ReleaseInfo `json: "myapplication"`
	}
)

// class http server expose api endpoint '/version'
func main() {
    fmt.Println("Starting Http server")
  	http.HandleFunc("/version", HandleGetVersion)
    // http.HandleFunc("/update", HandleUpdateVideos) 
    http.ListenAndServe(":8080", nil)
}
// function that produce the rseponse.
func HandleGetVersion(w http.ResponseWriter, r *http.Request){
  // for header, value := range r.Header {
  //   fmt.Printf("Key: %v \t Value: %v \n", header, value)
  // }
  w.Header().Set("Content-Type", "application/json")
 	w.WriteHeader(http.StatusOK)
  a := ReleaseInfo {
		Version: GitTag,
		CommitId: GitHash,
		Description: "Api for returning application info",
	}
  json.NewEncoder(w).Encode(ResBuilder{Content: []ReleaseInfo{a}})
}
