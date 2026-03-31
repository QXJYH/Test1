return function()
	local createMessageChunkChildren = require(script.Parent.createMessageChunkChildren)
	local PlainText = require(script.Parent.PlainText)

	local mockGlobalIdForChunks = 0
	local function createMessageChunk(message)
		mockGlobalIdForChunks = mockGlobalIdForChunks + 1
		return {
			id = mockGlobalIdForChunks,
			message = message,
		}
	end

	it("should return a table (dictionary)", function()
		local result = createMessageChunkChildren()
		expect(result).to.be.ok()
		expect(type(result)).to.equal("table")
	end)

	it("should return a dictionary with a PlainText element when given a single chunk", function()
		local mockHelloChunk = createMessageChunk("hello")

		local mockMessageChunks = {
			mockHelloChunk,
		}
		local props = {
			messageChunks = mockMessageChunks,
		}
		local result = createMessageChunkChildren(props)
		expect(result).to.be.ok()

		local messageChunkElement = result[mockHelloChunk.id]
		expect(messageChunkElement).to.be.ok()
		expect(messageChunkElement.component).to.equal(PlainText)
	end)

	it("should return dictionary of PlainText elements when given a multiple chunks", function()
		local mockFirstChunk = createMessageChunk("first")
		local mockSecondChunk = createMessageChunk("second")
		local mockThirdChunk = createMessageChunk("third")

		local mockMessageChunks = {
			mockFirstChunk,
			mockSecondChunk,
			mockThirdChunk
		}
		local props = {
			messageChunks = mockMessageChunks,
		}
		local result = createMessageChunkChildren(props)
		expect(result).to.be.ok()

		local messageChunkElementFirst = result[1]
		expect(messageChunkElementFirst).to.be.ok()
		expect(messageChunkElementFirst.component).to.equal(PlainText)

		local messageChunkElementSecond = result[2]
		expect(messageChunkElementSecond).to.be.ok()
		expect(messageChunkElementSecond.component).to.equal(PlainText)

		local messageChunkElementThird = result[3]
		expect(messageChunkElementThird).to.be.ok()
		expect(messageChunkElementThird.component).to.equal(PlainText)
	end)
end