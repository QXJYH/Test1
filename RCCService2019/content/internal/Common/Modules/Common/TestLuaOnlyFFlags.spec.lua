return function()
    local function scopedFastString(name, value, codeFn)
        local oldValue = game:SetFastStringForTesting(name, value);

        expect(codeFn).never.throw()
        game:SetFastStringForTesting(name, oldValue);
    end
    describe("declared flags from C++", function() -- passes
        it("should be extracted without errors", function()
            expect(game:GetFastString("LuaFlagsTestString")).to.equal("test string")
            expect(game:GetFastFlag("LuaFlagsTestFlag")).to.equal(true)
            expect(game:GetFastInt("LuaFlagsTestInt")).to.equal(12345)
        end)
    end)

    describe("declare flags from Lua", function()
        it("should work if defined without conflicts", function()
            expect(game:DefineFastString("LuaOnlyString", "lua only string")).to.equal("lua only string")
            expect(game:DefineFastFlag("LuaOnlyFlag", true)).to.equal(true)
            expect(game:DefineFastInt("LuaOnlyInt", 54321)).to.equal(54321)
        end)

        it("should be accessible with UseFFlags if defined without conflicts", function()
            expect(game:DefineFastString("LuaOnlyString", "lua only string")).to.equal("lua only string")
            expect(game:DefineFastFlag("LuaOnlyFlag", true)).to.equal(true)
            expect(game:DefineFastInt("LuaOnlyInt", 54321)).to.equal(54321)

            expect(game:GetFastString("LuaOnlyString")).to.equal("lua only string")
            expect(game:GetFastFlag("LuaOnlyFlag")).to.equal(true)
            expect(game:GetFastInt("LuaOnlyInt")).to.equal(54321)
        end)

        it("with same defaults as C++", function()
            expect(game:DefineFastString("LuaFlagsTestString", "test string")).to.equal("test string")
            expect(game:DefineFastFlag("LuaFlagsTestFlag", true)).to.equal(true)
            expect(game:DefineFastInt("LuaFlagsTestInt", 12345)).to.equal(12345)
        end)
        it("should be possible to change value in tests", function()
            game:DefineFastString("LuaOnlyString", "lua only string")

            local changedValue
            scopedFastString("LuaOnlyString", "other value", function()
                changedValue = game:GetFastString("LuaOnlyString")
            end)
            expect(changedValue).to.equal("other value")
            expect(game:GetFastString("LuaOnlyString")).to.equal("lua only string")
        end)
    end)
end