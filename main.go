package main

import (
	"io"
	"log"
	"net/http"

	restful "github.com/emicklei/go-restful/v3"
)

func main() {
	ws := new(restful.WebService)
	ws.Route(ws.GET("/test").To(testHandle))
	restful.Add(ws)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func testHandle(req *restful.Request, resp *restful.Response) {
	log.Printf("processing test request....")
	io.WriteString(resp, "hello happyman (version=0.0.1)\n")
}
