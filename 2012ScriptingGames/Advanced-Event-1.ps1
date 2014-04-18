for ($i = 1 ; $i -le 10 ; $i++) {
            $notepad = Get-Process notepad -ErrorAction SilentlyContinue
            if ($notepad.Responding) {$notepad}
            else {"Notepad not started"}
            start-sleep 1
            }