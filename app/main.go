package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

//Initializing global variables for GitTag and GitHash which later can be retrive from cicd
var GitTag = "v0.0.1"
var GitHash string

// Initializing struct for ReleaseInfo and Resbuilder which will be encoded for api response
type (
	ReleaseInfo struct {
		Version     string `json:"version"`
		CommitId    string `json:"lastcommitsha"`
		Description string `json:"description"`
	}
)
type (
	ResBuilder struct {
		Myapplication []ReleaseInfo `json:"myapplication"`
	}
)

// class http server expose api endpoint '/version'
func main() {
	fmt.Println("Starting Http server")
	http.HandleFunc("/version", HandleGetVersion)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

// function that produce the rseponse.
func HandleGetVersion(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	a := ReleaseInfo{
		Version:     GitTag,
		CommitId:    GitHash,
		Description: "Api for application info",
	}
	err := json.NewEncoder(w).Encode(ResBuilder{Myapplication: []ReleaseInfo{a}})
	if err != nil {
		panic(err)
	}
}
