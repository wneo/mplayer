package play

import (
	"fmt"
)

type Player interface {
	Play(source string)
}

func Play(source, mtype string) {
	var p Player
	switch mtype {
	case "mp3":
		p = &MP3Player{}
	case "wav":

	default:
		fmt.Println("Unsupported music type", mtype)
		return
	}

	p.Play(source)
}
