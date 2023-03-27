#!/usr/bin/env pwsh

Invoke-WebRequest https://www.deutschestextarchiv.de/basisformat.sch -OutFile .\src\main\schematron\basisformat.sch