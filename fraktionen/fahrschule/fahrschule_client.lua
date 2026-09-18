loadstring(exports.DGS:dgsImportFunction())()

local localPlayer = localPlayer
local drivingSchoolCorrectQuestions = 0
local drivingSchoolCurQuestion = 1

local examWindow
local questionLabel
local questionNumberLabel
local answerButtons = {}
local sendButton
local selectedAnswer = nil

-- Fragen kamen bisher IMMER in derselben Reihenfolge mit denselben
-- Antwortpositionen (A/B/C/D) - liess sich auswendig lernen, ohne die Frage
-- zu lesen. questionOrder wuerfelt bei jedem Versuch neu, in welcher
-- Reihenfolge die 7 Fragen drankommen; answerOrder wuerfelt pro Frage neu,
-- an welcher Position (A/B/C/D) welche Antwort steht.
local questionOrder = {}
local answerOrder = {}
local correctAnswerSlot = nil

local function shuffleTable(original)
    local kopie = {}
    for i, wert in ipairs(original) do kopie[i] = wert end
    for i = #kopie, 2, -1 do
        local j = math.random(i)
        kopie[i], kopie[j] = kopie[j], kopie[i]
    end
    return kopie
end


local drivingLicenses = {}
drivingLicenses["question"] = {
    [1]="Was ist bei Aquaplaning zu tun?",
    [2]="Welche Vorfahrt gilt an einem Kreisverkehr?",
    [3]="Was bedeutet dieses Verkehrszeichen? (Dreieck mit rotem Rand und Ausrufezeichen)",
    [4]="Wann musst du beim Abbiegen blinken?",
    [5]="Wie verhältst du dich an einem Fußgängerüberweg (Zebrastreifen)?",
    [6]="Was ist der richtige Abstand zum vorausfahrenden Fahrzeug?",
    [7]="Wann darfst du eine durchgezogene Linie überfahren?"
}
drivingLicenses["answereA"] = {
    [1]="Stark bremsen und das Lenkrad festhalten",
    [2]="Rechts vor Links",
    [3]="Vorsicht, Steinschlag!",
    [4]="Immer, wenn du die Fahrtrichtung änderst",
    [5]="Du hast Vorrang und darfst ungehindert fahren",
    [6]="Mindestens eine Fahrzeuglänge",
    [7]="Nur in Notfällen"
}
drivingLicenses["answereB"] = {
    [1]="Gas wegnehmen und nicht lenken",
    [2]="Wer zuerst in den Kreisverkehr einfährt, hat Vorfahrt",
    [3]="Achtung, Gegenverkehr",
    [4]="Nur beim Abbiegen an einer Kreuzung",
    [5]="Du musst anhalten und Fußgänger überqueren lassen",
    [6]="Der halbe Tacho in Metern (bei 100 km/h = 50 Meter)",
    [7]="Niemals"
}
drivingLicenses["answereC"] = {
    [1]="Weiter beschleunigen",
    [2]="Der Verkehr im Kreisverkehr hat Vorfahrt, außer es ist anders beschildert",
    [3]="Gefahrstelle",
    [4]="Nur, wenn du eine andere Straße befährst",
    [5]="Nur Kinder und Senioren haben Vorrang",
    [6]="Eine Sekunde Abstand",
    [7]="Nur, um ein Hindernis zu umfahren"
}
drivingLicenses["answereD"] = {
    [1]="Motor abstellen und ausrollen lassen",
    [2]="Der Verkehr, der aus dem Kreisverkehr herausfährt, hat Vorfahrt",
    [3]="Achtung, Baustelle",
    [4]="Das Blinken ist optional",
    [5]="Du fährst langsam weiter, wenn keine Fußgänger da sind",
    [6]="Zwei Sekunden Abstand",
    [7]="Nur in der Stadt"
}

drivingLicenses["correct"] = {
    [1]=2,
    [2]=3,
    [3]=3,
    [4]=4,
    [5]=2,
    [6]=2,
    [7]=2
}



local function highlightSelection(clickedButton)
    for _, btn in ipairs(answerButtons) do
        dgsSetProperty(btn, "textColor", tocolor(255, 255, 255, 255))
    end
    dgsSetProperty(clickedButton, "textColor", tocolor(0, 255, 255, 255))
end



function startDrivingLicenseTheory_func()
    drivingSchoolCorrectQuestions = 0
    drivingSchoolCurQuestion = 1
    questionOrder = shuffleTable({1, 2, 3, 4, 5, 6, 7})
    showExamWindow(drivingSchoolCurQuestion)
    guiSetInputMode("no_binds_when_editing")
    showCursor(true)
end

function showExamWindow(positionInOrder)
    drivingSchoolCurQuestion = positionInOrder

    if isElement(examWindow) then destroyElement(examWindow); examWindow = nil end

    local questionNR = questionOrder[positionInOrder]
    if not questionNR then
        showCursor(false)
        guiSetInputMode("allow_binds")
        return
    end

    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 550, 400
    local windowX, windowY = screenWidth / 2 - windowWidth / 2, screenHeight / 2 - windowHeight / 2

    examWindow = dgsCreateWindow(windowX, windowY, windowWidth, windowHeight, "Führerscheinprüfung", false, nil,nil,nil,nil,nil, tocolor(16,29,61,255))
    dgsBringToFront(examWindow)
    dgsSetProperty(examWindow, "image", false)
    dgsWindowSetMovable(examWindow, false)
    dgsWindowSetSizable(examWindow, false)

    selectedAnswer = nil

    questionNumberLabel = dgsCreateLabel(10, 20, windowWidth - 20, 30, "Frage "..tostring(positionInOrder).." / 7", false, examWindow)
    dgsLabelSetColor(questionNumberLabel, 255, 255, 100,255)

    questionLabel = dgsCreateLabel(20, 60, windowWidth - 40, 100, drivingLicenses["question"][questionNR], false, examWindow)

    dgsLabelSetHorizontalAlign(questionLabel, "center")
    dgsLabelSetVerticalAlign(questionLabel, "center")

    local answerOptions = {"A", "B", "C", "D"}
    local answerTextsOriginal = {
        drivingLicenses["answereA"][questionNR],
        drivingLicenses["answereB"][questionNR],
        drivingLicenses["answereC"][questionNR],
        drivingLicenses["answereD"][questionNR]
    }

    -- answerOrder[Anzeigeposition] = urspruengliche Position (1=A,2=B,3=C,4=D)
    -- in drivingLicenses. correctAnswerSlot merkt sich, an welcher
    -- ANGEZEIGTEN Position (nach dem Mischen) die richtige Antwort diesmal
    -- gelandet ist - das ist es, was der Sendbutton-Handler unten vergleicht.
    answerOrder = shuffleTable({1, 2, 3, 4})
    local correctOriginal = drivingLicenses["correct"][questionNR]
    correctAnswerSlot = nil
    for anzeigePos, urspruengPos in ipairs(answerOrder) do
        if urspruengPos == correctOriginal then
            correctAnswerSlot = anzeigePos
        end
    end

    local buttonWidth = 240
    local buttonHeight = 50
    local startY = 180
    local padding = 10

    answerButtons = {}
    for i=1, 4 do
        local x = (i % 2 == 1) and padding or (padding + buttonWidth + padding)
        local y = (math.ceil(i/2) == 1) and startY or (startY + buttonHeight + padding)

        local text = answerOptions[i]..": "..answerTextsOriginal[answerOrder[i]]

        answerButtons[i] = dgsCreateButton(x, y, buttonWidth, buttonHeight, text, false, examWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

        addEventHandler("onDgsMouseClickUp", answerButtons[i], function(button)
            if button == "left" then
                selectedAnswer = i
                highlightSelection(source)
            end
        end, false)
    end


    sendButton = dgsCreateButton(windowWidth/2 - 120/2, windowHeight - 60, 120, 40, "Absenden", false, examWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))


    addEventHandler("onDgsMouseClickUp", sendButton, function(button)
        if button == "left" then
            local currentSelection = selectedAnswer or 0

            if currentSelection == 0 then
                outputChatBox("Bitte wähle eine Antwort aus, bevor du absendest.", 255, 255, 0)
                return
            end

            if correctAnswerSlot == currentSelection then
                drivingSchoolCorrectQuestions = drivingSchoolCorrectQuestions + 1
            end

            destroyElement(examWindow)
            examWindow = nil

            if drivingSchoolCurQuestion < 7 then
                showExamWindow(drivingSchoolCurQuestion + 1)
            else
                triggerServerEvent("pruefungErgebnis", localPlayer, drivingSchoolCorrectQuestions)
                showCursor(false)
                guiSetInputMode("allow_binds")
            end
        end
    end, false)
end
addEvent("startDrivingLicenseTheory", true)
addEventHandler("startDrivingLicenseTheory", root, startDrivingLicenseTheory_func)