describe 'Test angular-selector', ->

	beforeEach (module 'rc/angularSelector')

	$httpBackend = null
	$log = null
	$timeout = null
	scope = null
	element = null
	rcAngularSelectorAjaxService = null
	rcAngularSelectorConfig = null
	rcAngularSelectorKeyboardEnum = null
	usSpinnerService = null
	mockSearchResult = [
		{
			"id": "53f398fc7d20b34e3d121f1e",
			"name": "Vilma"
		},
		{
			"id": "53f398fc14d2fa83cf810e42",
			"name": "Sullivan"
		},
		{
			"id": "53f398fc6a78ab35b5a96285",
			"name": "Francis"
		},
		{
			"id": "53f398fce606c55317269fef",
			"name": "Ann"
		},
		{
			"id": "53f398fcd622dab4d7d4f9f2",
			"name": "Cristina"
		},
		{
			"id": "53f398fc6facb4a9b2f22c75",
			"name": "Cannon"
		},
		{
			"id": "53f398fc96b3159e7bfeb392",
			"name": "Latisha"
		},
		{
			"id": "53f398fcf2b96a2257f2520b",
			"name": "Allison"
		}
	]
	mockSearchParams =
		limit: 20
		offset: 0

	beforeEach ->
		inject (_$httpBackend_,
			_$log_,
			_$timeout_,
			_rcAngularSelectorAjaxService_,
			_rcAngularSelectorConfig_,
			_rcAngularSelectorKeyboardEnum_,
			_usSpinnerService_) ->

			$httpBackend = _$httpBackend_
			$log = _$log_
			$timeout = _$timeout_
			rcAngularSelectorAjaxService = _rcAngularSelectorAjaxService_
			rcAngularSelectorConfig = _rcAngularSelectorConfig_
			rcAngularSelectorKeyboardEnum = _rcAngularSelectorKeyboardEnum_
			usSpinnerService = _usSpinnerService_

			# The httpBackend mocks
			$httpBackend
				.whenGET /\/jax\/getMarketsBySearchString(\?.*)?/
				.respond mockSearchResult

	describe 'Test directives', ->

		beforeEach ->
			inject ($compile, $rootScope) ->

				scope = do $rootScope.$new
				angular.extend scope,
					searchUrl: '/jax/getMarketsBySearchString'
					searchParams: mockSearchParams
					selectOptions: (mockSearchResult.slice 0, 4).map (result) ->
						id: result.id
						text: result.name
					userSession:
						name: 'Ryan'
						id: '123'
						homeMarket: '1'
					selections: []
					defaultSelections: mockSearchResult.slice 0, 2
					resultMap: [{
						id: 'id',
						text: 'name'
						}]

				element = angular.element """
				<rc-angular-selector
					selections="selections"
					search-url="searchUrl"
					search-params="searchParams"
					select-options="selectOptions"
					multiple="true"
					default-selections="defaultSelections"
					result-map="resultMap"></rc-angular-selector>
				"""

				($compile element) scope
				do scope.$apply
				scope = (do element.scope).$$childHead

		describe 'Test angular-selector directive', ->

			describe '#init', ->

				it 'should set the default selection if there is any', ->
					expect scope.selections.length
					.toBe (do scope.defaultSelections).length

			describe '#prepareSelection', ->

				it 'should extend the selection with __id and __text', ->
					fakeSelection =
						id: '2234'
						name: '4456'
					scope.prepareSelection fakeSelection
					expect fakeSelection.__id
					.toBe fakeSelection.id
					expect fakeSelection.__text
					.toBe fakeSelection.name

			describe '#loadDefaultSelections', ->

				it 'should load default selections if there is one', ->
					fakeSelection =
						id: '2234'
						name: '4456'
					scope.selections.length = 0

					do scope.loadDefaultSelections
					expect scope.selections.length
					.toBe (do scope.defaultSelections).length

		describe 'Test angular-selector-input directive', ->

			describe '#selectResult', ->

				it 'should have id and text to process', ->
					mockSearchResult_good =
						id: '123',
						text: 'mock'

					spyOn $log, 'warn'
					scope.selectResult mockSearchResult_good
					expect $log.warn
					.not.toHaveBeenCalledWith('Invalid searchResult')

				it 'should add selection to selections in data service', ->
					selections = scope.selections
					expect selections.length
					.toBe (do scope.defaultSelections).length

					mockSearchResult_good =
						id: '123',
						text: 'mock'
					scope.selectResult mockSearchResult_good
					expect selections.length
					.toBe (do scope.defaultSelections).length + 1

			describe '#removeSelection', ->

				it 'should remove the given selection', ->
					expect scope.selections.length
					.toBe (do scope.defaultSelections).length

					scope.removeSelection scope.selections[0]
					expect scope.selections.length
					.toBe (do scope.defaultSelections).length - 1

				it 'should focus the input box if there is empty selection', ->
					scope.selections.length = 1
					spyOn scope, 'focusInputBox'
					scope.removeSelection scope.selections[0]
					expect scope.focusInputBox
					.toHaveBeenCalled()

			describe '#fetch', ->

				it 'should call #getSearchResult with url and params, if url is given', ->
					spyOn rcAngularSelectorAjaxService, 'getSearchResult'
					.and.returnValue
						then: ->
							finally: ->
					do scope.fetch
					expect rcAngularSelectorAjaxService.getSearchResult
					.toHaveBeenCalledWith do scope.searchUrl, scope.updatedSearchParams

				it 'should use the given selectOptions, if url is not given', ->
					scope.searchUrl = ->
					spyOn rcAngularSelectorAjaxService, 'getSearchResult'
					spyOn scope, 'fetchSucceed'
					do scope.fetch
					expect rcAngularSelectorAjaxService.getSearchResult
					.not.toHaveBeenCalled()
					scope.$apply()
					expect scope.fetchSucceed
					.toHaveBeenCalled()

				it 'should start the spinner when fetch', ->
					spyOn usSpinnerService, 'spin'
					do scope.fetch
					expect usSpinnerService.spin
					.toHaveBeenCalledWith scope.usSpinnerKey

				it 'should call #fetchSucceed when succeed', ->
					spyOn scope, 'fetchSucceed'
					do scope.fetch
					do $httpBackend.flush
					expect scope.fetchSucceed
					.toHaveBeenCalled()

				it 'should make usSpinnerService call #stop finally', ->
					spyOn usSpinnerService, 'stop'
					do scope.fetch
					do $httpBackend.flush
					expect usSpinnerService.stop
					.toHaveBeenCalled()

			describe '#fetchSucceed', ->
				fakeResponse = {
				    "data": mockSearchResult,
				    "status": 200,
				    "config": {
				        "method": "GET",
				        "transformRequest": [null],
				        "transformResponse": [null],
				        "url": "/jax/getMarketsBySearchString",
				        "params": {
				            "limit": 20,
				            "offset": 0
				        },
				        "headers": {
				            "Accept": "application/json, text/plain, */*"
				        }
				    },
				    "statusText": "OK"
				}

				it 'should replace the searchResult array when offset is zero', ->
					spyOn scope, 'replace'
					scope.fetchSucceed fakeResponse
					expect scope.replace
					.toHaveBeenCalled()

				it 'should append the searchResult array when offset is greater than zero', ->
					spyOn scope, 'append'
					fakeResponse.config.params.offset = 20
					scope.fetchSucceed fakeResponse
					expect scope.append
					.toHaveBeenCalled()

				it 'should update hasMore flag according to the response', ->
					scope.fetchSucceed fakeResponse
					expect scope.hasMore
					.toBe false

					fakeResponse.config.params.limit = mockSearchResult.length
					scope.fetchSucceed fakeResponse
					expect scope.hasMore
					.toBe true

				it 'should fetch the correct results by given results key', inject ($compile, $rootScope) ->
					scope = do $rootScope.$new
					angular.extend scope,
						searchUrl: '/jax/getMarketsBySearchString'
						searchParams: mockSearchParams
						userSession:
							name: 'Ryan'
							id: '123'
							homeMarket: '1'
						resultMap: ['markets',
							id: 'id',
							text: 'text'
						]

					element = angular.element """
					<rc-angular-selector
						selections="selections"
						search-url="searchUrl"
						result-map="resultMap"
						search-params="searchParams"
						session="userSession"
						multiple="true"
						typeahead="true"
						tolerance="5"></rc-angular-selector>
					"""

					($compile element) scope
					do scope.$apply
					scope = (do element.scope).$$childHead

					spyOn scope, 'replace'
					fakeResponse.data =
						markets: mockSearchResult
					fakeResponse.config.params.offset = 0
					scope.fetchSucceed fakeResponse
					expect scope.replace
					.toHaveBeenCalledWith mockSearchResult

			describe '#fetchFailure', ->

				it 'should warn people', ->
					spyOn $log, 'error'
					do scope.fetchFailure
					expect $log.error
					.toHaveBeenCalled()

			describe '#replace', ->

				it 'should replace the searchResults array', ->
					scope.searchResults = [{
						'id': '123',
						'text': 'my mock data'
					}]
					scope.replace mockSearchResult
					expect scope.searchResults
					.toBe mockSearchResult

				it 'should update the search offset', ->
					scope.updatedSearchParams.offset = 10
					scope.replace mockSearchResult
					expect scope.updatedSearchParams.offset
					.toBe mockSearchResult.length

			describe '#append', ->

				it 'should append the searchResults array', ->
					scope.searchResults = [{
						'id': '123',
						'text': 'my mock data'
					}]
					scope.append mockSearchResult
					expect scope.searchResults.length
					.toBe mockSearchResult.length + 1

				it 'should update the search offset', ->
					scope.updatedSearchParams.offset = 10
					scope.append mockSearchResult
					expect scope.updatedSearchParams.offset
					.toBe 10 + mockSearchResult.length

			# describe '#deleteSelectionById', ->

			# 	it 'should delete the selection from selections array by id', ->
			# 		scope.selections = [{
			# 			'id': '123',
			# 			'text': 'my mock data'
			# 		}]
			# 		scope.deleteSelectionById '123'
			# 		expect scope.selections.length
			# 		.toBe 0

			describe '#handleInputBoxFocus', ->

				it 'should set the selecting status', ->
					expect scope.isSelecting
					.toBe false

					do scope.handleInputBoxFocus
					expect scope.isSelecting
					.toBe true

			describe '#handleInputBoxBlur', ->

				it 'should reset stuffs', ->
					spyOn scope, 'resetInputBox'
					spyOn scope, 'resetSearchParams'
					spyOn scope, 'resetHasMore'
					do scope.handleInputBoxBlur
					expect scope.resetInputBox
					.toHaveBeenCalled()
					expect scope.resetSearchParams
					.toHaveBeenCalled()
					expect scope.resetHasMore
					.toHaveBeenCalled()
					expect scope.searchResults.length
					.toBe 0

				it 'should focus the input box again when it\'s multiple mode and just selected', ->
					scope.isSelected = true
					scope.multiple = ->
						true
					spyOn scope, 'focusInputBox'
					do scope.handleInputBoxBlur
					expect scope.focusInputBox
					.toHaveBeenCalled()

				it 'should focus void the selecting state', ->
					scope.multiple = false
					scope.isSelecting = true
					do scope.handleInputBoxBlur
					expect scope.isSelecting
					.toBe false

				it 'should load default selections when there is no selection and there is default', ->
					scope.selections.length = 0
					spyOn scope, 'loadDefaultSelections'

					do scope.handleInputBoxBlur
					expect scope.loadDefaultSelections
					.toHaveBeenCalled()

			describe '#handleSearchStringChange', ->

				it 'should set the offset to 0', ->
					scope.updatedSearchParams.offset = 20
					do scope.handleSearchStringChange
					expect scope.updatedSearchParams.offset
					.toBe 0

				it 'should call fetch to fetch new data', ->
					spyOn scope, 'fetch'
					do scope.handleSearchStringChange
					expect scope.fetch
					.toHaveBeenCalled()

			describe '#blurInputBox', ->

				it 'should blur the input box', ->
					spyOn scope, 'handleInputBoxBlur'
					do scope.blurInputBox
					do $timeout.flush
					expect scope.handleInputBoxBlur
					.toHaveBeenCalled()

			describe '#focusInputBox', ->

				mockClickEvent =
					target: """
						<li class="angular-selector-selection">
							<span>abc</span>
						</li>
					"""

				it 'should do nothing if we click on a option', inject ($timeout) ->
					inputElement = element.find('input')[0]
					spyOn inputElement, 'focus'
					scope.focusInputBox mockClickEvent
					do $timeout.flush
					expect inputElement.focus
					.not.toHaveBeenCalled()

				it 'should focus the inputbox when no click event passed in', ->
					inputElement = element.find('input')[0]
					spyOn inputElement, 'focus'
					do scope.focusInputBox
					do $timeout.flush
					expect inputElement.focus
					.toHaveBeenCalled()

				it 'should void the isSelected state', ->
					scope.isSelected = true
					do scope.focusInputBox
					do $timeout.flush
					expect scope.isSelected
					.toBe false

			describe '#handleKeydownResponse', ->

				it 'should increse verticalIndex by 1 when click down arrow', ->
					mockKeyEvent =
						keyCode: rcAngularSelectorKeyboardEnum.DOWN_ARROW
					scope.verticalIndex = -1
					scope.handleKeydownResponse mockKeyEvent
					expect scope.verticalIndex
					.toBe 0

				it 'should decrease verticalIndex by 1 when click up arrow', ->
					mockKeyEvent =
						keyCode: rcAngularSelectorKeyboardEnum.UP_ARROW
					scope.verticalIndex = 0
					scope.handleKeydownResponse mockKeyEvent
					expect scope.verticalIndex
					.toBe -1

				it 'should increse horizontalIndex by 1 when click left arrow', ->
					mockKeyEvent =
						keyCode: rcAngularSelectorKeyboardEnum.LEFT_ARROW
					scope.horizontalIndex = 0
					scope.handleKeydownResponse mockKeyEvent
					expect scope.horizontalIndex
					.toBe -1

				it 'should decrease horizontalIndex by 1 when click right arrow', ->
					mockKeyEvent =
						keyCode: rcAngularSelectorKeyboardEnum.RIGHT_ARROW
					scope.horizontalIndex = 0
					scope.handleKeydownResponse mockKeyEvent
					expect scope.horizontalIndex
					.toBe 1

			describe '#resetVerticalIndex', ->

				it 'should reset the vertical index to given number', ->
					scope.resetVerticalIndex 10
					expect scope.verticalIndex
					.toBe 10

					do scope.resetVerticalIndex
					expect scope.verticalIndex
					.toBe -1

			describe '#handleMouseoverOnSearchResults', ->

				it 'should reset the verticalIndex to current search result index', ->
					scope.handleMouseoverOnSearchResults 10
					expect scope.verticalIndex
					.toBe 10

			describe '#resetInputBox', ->

				it 'should reset the inputbox value to ""', ->
					inputElement = element.find('input')
					inputElement.val 'abc'
					do scope.resetInputBox
					expect do inputElement.val
					.toBe ''

			describe '#resetSearchParams', ->

				it 'should reset the search params to user defaults', ->
					scope.searchParams = ->
						offset: mockSearchParams.offset
					scope.updatedSearchParams =
						offset: mockSearchParams.offset + 100
					do scope.resetSearchParams
					expect scope.updatedSearchParams.offset
					.toBe mockSearchParams.offset

			describe '#resetHasMore', ->

				it 'should reset the hasMore state to true', ->
					scope.hasMore = false
					do scope.resetHasMore
					expect scope.hasMore
					.toBe true

			describe '#updateSearchParams', ->

				it 'should update the searchParams with new offset and limit', ->
					scope.updateSearchParams
						offset: 40
					expect scope.updatedSearchParams.offset
					.toBe 40

			describe '#validateSearchResult', ->

				it 'should find out if the searchResult has id and text', ->
					fakeBadSearchResult =
						id: '123',
						name: 'john'
					expect scope.validateSearchResult fakeBadSearchResult
					.toBe false

					fakeBadSearchResult =
						_id: '123',
						text: 'john'
					expect scope.validateSearchResult fakeBadSearchResult
					.toBe false

					fakeBadSearchResult =
						__id: '123',
						__text: 'john'
					expect scope.validateSearchResult fakeBadSearchResult
					.toBe true

			describe 'watch searchParams.searchString', ->

				it 'should call #handleSearchStringChange', ->
					# TODO: the test with debounce is tricky

					# scope.searchParams.searchString = 'aaa'
					# waitsFor ->
					# 	scope.searchParams.searchString

					# runs ->
					# 	spyOn scope, 'handleSearchStringChange'
					# 	scope.searchParams.searchString = 'bbb'
					# 	do scope.$digest
					# 	expect scope.handleSearchStringChange
					# 	.toHaveBeenCalled()

			describe 'watch selections.length', ->

				it 'should set the horizontalIndex by selection length - 1', ->
					scope.selections = [{
						'id': '123',
						'text': 'my mock data'
					}]
					scope.horizontalIndex = scope.selections.length + 100
					do scope.$digest
					expect scope.horizontalIndex
					.toBe scope.selections.length - 1
