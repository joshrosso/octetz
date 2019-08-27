package main

import (
	"fmt"
	bf "github.com/russross/blackfriday"
	"gopkg.in/src-d/go-git.v4"
	"io/ioutil"
	"os"
)

type Website struct {
	outputLocation string
	templateLocation string
	gitCacheLocation string
	posts []Post
}

type Post struct {
	name string
	gitUrl string
}

func main() {
	ps := []Post{
		{
			name:   "setting-up-psps",
			gitUrl: "https://github.com/octetz/setting-up-psps",
		},
	}

	w := Website{
		outputLocation:   "",
		templateLocation: "",
		gitCacheLocation: "./tmp",
		posts:            ps,
	}


	_, err := git.PlainClone(w.gitCacheLocation+"/"+w.posts[0].name, false, &git.CloneOptions{
		URL:      w.posts[0].gitUrl,
		Progress: os.Stdout,
	})

	if err != nil {
		fmt.Println(err)
	}

	b, err := ioutil.ReadFile(w.gitCacheLocation+"/"+w.posts[0].name+"/README.md")

	if err != nil {
		fmt.Println(err)
	}

	output := bf.Run(b)
	fmt.Printf("%s", output)
}
