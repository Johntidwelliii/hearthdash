{View, $$, $} = require 'space-pen'

CardView = require './card-view'
_ = require 'underscore'

module.exports = class DeckView extends View
	@content: (params) ->
		@div class: 'deck-view', =>
			@div class: 'deck-name', outlet: 'deckName', params.name
			@div class: 'deck-list', outlet: 'deckList'

	cards: null
	cardCount: 0
	turn: 0
	defaults:
		keepCards: false
		trackTurns: false
		sorted: false

	initialize: (params) ->
		@params = _.extend {}, @defaults, params
		@cards = {}
		@cardCount = 0
		@turn = 0
		@currentTurn = null
		@previousController = false
		if @params.trackTurns
			@addClass 'track-turns'

	setName: (name) ->
		@params.name = name
		@update()

	setTurn: (turn) ->
		if turn isnt @turn
			@turn = turn

			@deckList.prepend @currentTurn = $$ -> @div class: 'deck-turn', 'data-turn': turn
			@currentTurn.hide()

	addCard: (card, animate=true, controller='player') ->
		@cardCount++
		cardView = new CardView id: card
		cardView.addClass 'controller-' + controller
		existed = false
		if @cards[card]
			existed = true
		else
			@cards[card] = cardView

		if @params.trackTurns
			@currentTurn.show()
			@currentTurn.prepend cardView
			cardView.slideDown() if animate
		else
			if existed
				@cards[card].increment()
			else
				if @params.sorted
					insertionPoint = _.find @deckList.children(), (b) ->
						[a, b] = [cardView, $(b).view()]
						ac = parseInt a.card.cost, 10
						bc = parseInt b.card.cost, 10

						if bc > ac
							return true

						else if bc == ac
							an = a.card.name
							bn = b.card.name
							if bn > an
								return true

						return false

					if insertionPoint
						$(insertionPoint).before cardView
					else
						@deckList.append cardView
				else
					@deckList.append cardView

		if animate
			cardView.slideDown()

		@previousController = controller
		@update()

		@cardCount

	removeCard: (card, animate=false) ->
		@cardCount--
		if @cards[card]
			@cards[card].decrement()
			if animate
				clone = @cards[card].clone()
				$('body').append(clone)
				pos = @cards[card].offset()
				clone.css
					'pointer-events': 'none'
					'position': 'absolute'
					'top': pos.top
					'left': pos.left
					'width': @cards[card].width()
					'opacity', 1
				clone.animate
					'margin-top': '-13px'
					'opacity': 0
				, 700, ->


			unless @params.keepCards or @cards[card].count
				@cards[card].slideUp -> $(this).view().remove()
				delete @cards[card]


		@update()

		@cardCount

	getCardList: ->
		cards = []
		for id, card of @cards
			for i in [0...card.count]
				cards.push id

		cards

	setDeck: (deck) ->
		@empty()

		for card in deck.cards
			@addCard card, false

		@update()

	empty: ->
		@deckList.empty()
		@cards = {}
		@cardCount = 0

		@update()

	update: ->
		text = @params.name
		if @cardCount
			text += ' (' + @cardCount + ')'
		@deckName.text text
