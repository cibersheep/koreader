describe("util module", function()
    local util
    setup(function()
        require("commonrequire")
        util = require("util")
    end)

    it("should strip punctuations around word", function()
        assert.is_equal(util.stripePunctuations("\"hello world\""), "hello world")
        assert.is_equal(util.stripePunctuations("\"hello world?\""), "hello world")
        assert.is_equal(util.stripePunctuations("\"hello, world?\""), "hello, world")
        assert.is_equal(util.stripePunctuations("“你好“"), "你好")
        assert.is_equal(util.stripePunctuations("“你好?“"), "你好")
    end)

    it("should split string with patterns", function()
        local sentence = "Hello world, welcome to KOReader!"
        local words = {}
        for word in util.gsplit(sentence, "%s+", false) do
            table.insert(words, word)
        end
        assert.are_same(words, {"Hello", "world,", "welcome", "to", "KOReader!"})
    end)

    it("should split command line arguments with quotation", function()
        local command = "./sdcv -nj \"words\" \"a lot\" 'more or less' --data-dir=dict"
        local argv = {}
        for arg1 in util.gsplit(command, "[\"'].-[\"']", true) do
            for arg2 in util.gsplit(arg1, "^[^\"'].-%s+", true) do
                for arg3 in util.gsplit(arg2, "[\"']", false) do
                    local trimed = arg3:gsub("^%s*(.-)%s*$", "%1")
                    if trimed ~= "" then
                        table.insert(argv, trimed)
                    end
                end
            end
        end
        assert.are_same(argv, {"./sdcv", "-nj", "words", "a lot", "more or less", "--data-dir=dict"})
    end)

    it("should split line into words", function()
        local words = util.splitToWords("one two,three  four . five")
        assert.are_same(words, {
            "one",
            " ",
            "two",
            ",",
            "three",
            "  ",
            "four",
            " . ",
            "five",
        })
    end)

    it("should split ancient greek words", function()
        local words = util.splitToWords("Λαρισαῖος Λευκοθέα Λιγυαστάδης.")
        assert.are_same(words, {
            "Λαρισαῖος",
            " ",
            "Λευκοθέα",
            " ",
            "Λιγυαστάδης",
            "."
        })
    end)

    it("should split Chinese words", function()
        local words = util.splitToWords("彩虹是通过太阳光的折射引起的。")
        assert.are_same(words, {
            "彩","虹","是","通","过","太","阳","光","的","折","射","引","起","的","。",
        })
    end)

    it("should split words of multilingual text", function()
        local words = util.splitToWords("BBC纪录片")
        assert.are_same(words, {"BBC", "纪", "录", "片"})
    end)

    it("should split text to line - unicode", function()
        local text = "Pójdźże, chmurność glück schließen Štěstí neštěstí. Uñas gavilán"
        local word = ""
        local table_of_words = {}
        local c
        local table_chars = util.splitToChars(text)
        for i = 1, #table_chars  do
            c = table_chars[i]
            word = word .. c
            if util.isSplitable(c) then
                table.insert(table_of_words, word)
                word = ""
            end
            if i == #table_chars then table.insert(table_of_words, word) end
        end
        assert.are_same(table_of_words, {
            "Pójdźże,",
            " ",
            "chmurność ",
            "glück ",
            "schließen ",
            "Štěstí ",
            "neštěstí.",
            " ",
            "Uñas ",
            "gavilán",
        })
    end)

    it("should split text to line - CJK", function()
        local text = "彩虹是通过太阳光的折射引起的。"
        local word = ""
        local table_of_words = {}
        local c
        local table_chars = util.splitToChars(text)
        for i = 1, #table_chars  do
            c = table_chars[i]
            word = word .. c
            if util.isSplitable(c) then
                table.insert(table_of_words, word)
                word = ""
            end
            if i == #table_chars then table.insert(table_of_words, word) end
        end
        assert.are_same(table_of_words, {
            "彩","虹","是","通","过","太","阳","光","的","折","射","引","起","的","。",
        })
    end)

end)
