{ ... }: {

  programs.wofi.style = ''
    window {
        margin: 5px;
        # border: 2px solid white; /* белая рамка */
        background-color: black;  /* чёрный фон */
        border-radius: 0px;
    }

    #outer-box {
        margin: 0;
        padding: 0;
        border: none;
        border: 2px solid white; /* белая рамка */
    }

    #inner-box {
        margin: 0;
        padding: 0;
    }

    #scroll {
        border: none;
        background-color: black;
    }

    #input {
        outline:none;

        border-radius:0;
        margin: 2px;
        border: none;
        background-color: black;
        color: white;
        font-family: monospace;
        font-size: 12pt;
    }

    #entry {
        margin: 0;
        padding: 2px 4px;
        border: none;
        background-color: black;
        color: white;
    }
    #text {
        color: white;
    }

    #entry:selected {
        background-color: rgba(255,255,255,0.1); /* легкий highlight */
    }

    #text:selected {
        color: white;
    }

  '';
}
