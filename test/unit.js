(function() {
  describe('Test angular-selector', function() {
    var $httpBackend, $log, $timeout, element, mockSearchParams, mockSearchResult, rcAngularSelectorAjaxService, rcAngularSelectorConfig, rcAngularSelectorKeyboardEnum, scope, usSpinnerService;
    beforeEach(module('rc/angularSelector'));
    $httpBackend = null;
    $log = null;
    $timeout = null;
    scope = null;
    element = null;
    rcAngularSelectorAjaxService = null;
    rcAngularSelectorConfig = null;
    rcAngularSelectorKeyboardEnum = null;
    usSpinnerService = null;
    mockSearchResult = [
      {
        "id": "53f398fc7d20b34e3d121f1e",
        "name": "Vilma"
      }, {
        "id": "53f398fc14d2fa83cf810e42",
        "name": "Sullivan"
      }, {
        "id": "53f398fc6a78ab35b5a96285",
        "name": "Francis"
      }, {
        "id": "53f398fce606c55317269fef",
        "name": "Ann"
      }, {
        "id": "53f398fcd622dab4d7d4f9f2",
        "name": "Cristina"
      }, {
        "id": "53f398fc6facb4a9b2f22c75",
        "name": "Cannon"
      }, {
        "id": "53f398fc96b3159e7bfeb392",
        "name": "Latisha"
      }, {
        "id": "53f398fcf2b96a2257f2520b",
        "name": "Allison"
      }
    ];
    mockSearchParams = {
      limit: 20,
      offset: 0
    };
    beforeEach(function() {
      return inject(function(_$httpBackend_, _$log_, _$timeout_, _rcAngularSelectorAjaxService_, _rcAngularSelectorConfig_, _rcAngularSelectorKeyboardEnum_, _usSpinnerService_) {
        $httpBackend = _$httpBackend_;
        $log = _$log_;
        $timeout = _$timeout_;
        rcAngularSelectorAjaxService = _rcAngularSelectorAjaxService_;
        rcAngularSelectorConfig = _rcAngularSelectorConfig_;
        rcAngularSelectorKeyboardEnum = _rcAngularSelectorKeyboardEnum_;
        usSpinnerService = _usSpinnerService_;
        return $httpBackend.whenGET(/\/jax\/getMarketsBySearchString(\?.*)?/).respond(mockSearchResult);
      });
    });
    return describe('Test directives', function() {
      beforeEach(function() {
        return inject(function($compile, $rootScope) {
          scope = $rootScope.$new();
          angular.extend(scope, {
            searchUrl: '/jax/getMarketsBySearchString',
            searchParams: mockSearchParams,
            userSession: {
              name: 'Ryan',
              id: '123',
              homeMarket: '1'
            },
            selections: [],
            defaultSelections: mockSearchResult.slice(0, 2),
            resultKeys: [
              {
                id: 'id',
                text: 'name'
              }
            ]
          });
          element = angular.element("<rc-angular-selector\n	selections=\"selections\"\n	search-url=\"searchUrl\"\n	search-params=\"searchParams\"\n	session=\"userSession\"\n	multiple=\"true\"\n	typeahead=\"true\"\n	tolerance=\"5\"\n	default-selections=\"defaultSelections\"\n	result-keys=\"resultKeys\"></rc-angular-selector>");
          ($compile(element))(scope);
          scope.$apply();
          return scope = (element.scope()).$$childHead;
        });
      });
      describe('Test angular-selector directive', function() {
        describe('#init', function() {
          return it('should set the default selection if there is any', function() {
            return expect(scope.selections.length).toBe((scope.defaultSelections()).length);
          });
        });
        describe('#prepareSelection', function() {
          return it('should extend the selection with __id and __text', function() {
            var fakeSelection;
            fakeSelection = {
              id: '2234',
              name: '4456'
            };
            scope.prepareSelection(fakeSelection);
            expect(fakeSelection.__id).toBe(fakeSelection.id);
            return expect(fakeSelection.__text).toBe(fakeSelection.name);
          });
        });
        return describe('#loadDefaultSelections', function() {
          return it('should load default selections if there is one', function() {
            var fakeSelection;
            fakeSelection = {
              id: '2234',
              name: '4456'
            };
            scope.selections.length = 0;
            scope.loadDefaultSelections();
            return expect(scope.selections.length).toBe((scope.defaultSelections()).length);
          });
        });
      });
      return describe('Test angular-selector-input directive', function() {
        describe('#selectResult', function() {
          it('should have id and text to process', function() {
            var mockSearchResult_good;
            mockSearchResult_good = {
              id: '123',
              text: 'mock'
            };
            spyOn($log, 'warn');
            scope.selectResult(mockSearchResult_good);
            return expect($log.warn).not.toHaveBeenCalledWith('Invalid searchResult');
          });
          return it('should add selection to selections in data service', function() {
            var mockSearchResult_good, selections;
            selections = scope.selections;
            expect(selections.length).toBe((scope.defaultSelections()).length);
            mockSearchResult_good = {
              id: '123',
              text: 'mock'
            };
            scope.selectResult(mockSearchResult_good);
            return expect(selections.length).toBe((scope.defaultSelections()).length + 1);
          });
        });
        describe('#removeSelection', function() {
          it('should remove the given selection', function() {
            expect(scope.selections.length).toBe((scope.defaultSelections()).length);
            scope.removeSelection(scope.selections[0]);
            return expect(scope.selections.length).toBe((scope.defaultSelections()).length - 1);
          });
          return it('should focus the input box if there is empty selection', function() {
            scope.selections.length = 1;
            spyOn(scope, 'focusInputBox');
            scope.removeSelection(scope.selections[0]);
            return expect(scope.focusInputBox).toHaveBeenCalled();
          });
        });
        describe('#fetch', function() {
          it('should call #getSearchResult with url and params', function() {
            spyOn(rcAngularSelectorAjaxService, 'getSearchResult').and.returnValue({
              then: function() {
                return {
                  "finally": function() {}
                };
              }
            });
            scope.fetch();
            return expect(rcAngularSelectorAjaxService.getSearchResult).toHaveBeenCalledWith(scope.searchUrl(), scope.searchParams);
          });
          it('should start the spinner when fetch', function() {
            spyOn(usSpinnerService, 'spin');
            scope.fetch();
            return expect(usSpinnerService.spin).toHaveBeenCalledWith(scope.usSpinnerKey);
          });
          it('should call #fetchSucceed when succeed', function() {
            spyOn(scope, 'fetchSucceed');
            scope.fetch();
            $httpBackend.flush();
            return expect(scope.fetchSucceed).toHaveBeenCalled();
          });
          return it('should make usSpinnerService call #stop finally', function() {
            spyOn(usSpinnerService, 'stop');
            scope.fetch();
            $httpBackend.flush();
            return expect(usSpinnerService.stop).toHaveBeenCalled();
          });
        });
        describe('#fetchSucceed', function() {
          var fakeResponse;
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
          };
          it('should replace the searchResult array when offset is zero', function() {
            spyOn(scope, 'replace');
            scope.fetchSucceed(fakeResponse);
            return expect(scope.replace).toHaveBeenCalled();
          });
          it('should append the searchResult array when offset is greater than zero', function() {
            spyOn(scope, 'append');
            fakeResponse.config.params.offset = 20;
            scope.fetchSucceed(fakeResponse);
            return expect(scope.append).toHaveBeenCalled();
          });
          it('should update hasMore flag according to the response', function() {
            scope.fetchSucceed(fakeResponse);
            expect(scope.hasMore).toBe(false);
            fakeResponse.config.params.limit = mockSearchResult.length;
            scope.fetchSucceed(fakeResponse);
            return expect(scope.hasMore).toBe(true);
          });
          return it('should fetch the correct results by given results key', inject(function($compile, $rootScope) {
            scope = $rootScope.$new();
            angular.extend(scope, {
              searchUrl: '/jax/getMarketsBySearchString',
              searchParams: mockSearchParams,
              userSession: {
                name: 'Ryan',
                id: '123',
                homeMarket: '1'
              },
              resultKeys: [
                'markets', {
                  id: 'id',
                  text: 'text'
                }
              ]
            });
            element = angular.element("<rc-angular-selector\n	selections=\"selections\"\n	search-url=\"searchUrl\"\n	result-keys=\"resultKeys\"\n	search-params=\"searchParams\"\n	session=\"userSession\"\n	multiple=\"true\"\n	typeahead=\"true\"\n	tolerance=\"5\"></rc-angular-selector>");
            ($compile(element))(scope);
            scope.$apply();
            scope = (element.scope()).$$childHead;
            spyOn(scope, 'replace');
            fakeResponse.data = {
              markets: mockSearchResult
            };
            fakeResponse.config.params.offset = 0;
            scope.fetchSucceed(fakeResponse);
            return expect(scope.replace).toHaveBeenCalledWith(mockSearchResult);
          }));
        });
        describe('#fetchFailure', function() {
          return it('should warn people', function() {
            spyOn($log, 'error');
            scope.fetchFailure();
            return expect($log.error).toHaveBeenCalled();
          });
        });
        describe('#replace', function() {
          it('should replace the searchResults array', function() {
            scope.searchResults = [
              {
                'id': '123',
                'text': 'my mock data'
              }
            ];
            scope.replace(mockSearchResult);
            return expect(scope.searchResults).toBe(mockSearchResult);
          });
          return it('should update the search offset', function() {
            scope.searchParams.offset = 10;
            scope.replace(mockSearchResult);
            return expect(scope.searchParams.offset).toBe(mockSearchResult.length);
          });
        });
        describe('#append', function() {
          it('should append the searchResults array', function() {
            scope.searchResults = [
              {
                'id': '123',
                'text': 'my mock data'
              }
            ];
            scope.append(mockSearchResult);
            return expect(scope.searchResults.length).toBe(mockSearchResult.length + 1);
          });
          return it('should update the search offset', function() {
            scope.searchParams.offset = 10;
            scope.append(mockSearchResult);
            return expect(scope.searchParams.offset).toBe(mockSearchResult.length + 10);
          });
        });
        describe('#handleInputBoxFocus', function() {
          return it('should set the selecting status', function() {
            expect(scope.isSelecting).toBe(false);
            scope.handleInputBoxFocus();
            return expect(scope.isSelecting).toBe(true);
          });
        });
        describe('#handleInputBoxBlur', function() {
          it('should reset stuffs', function() {
            spyOn(scope, 'resetInputBox');
            spyOn(scope, 'resetSearchParams');
            spyOn(scope, 'resetHasMore');
            scope.handleInputBoxBlur();
            expect(scope.resetInputBox).toHaveBeenCalled();
            expect(scope.resetSearchParams).toHaveBeenCalled();
            expect(scope.resetHasMore).toHaveBeenCalled();
            return expect(scope.searchResults.length).toBe(0);
          });
          it('should focus the input box again when it\'s multiple mode and just selected', function() {
            scope.isSelected = true;
            scope.multiple = function() {
              return true;
            };
            spyOn(scope, 'focusInputBox');
            scope.handleInputBoxBlur();
            return expect(scope.focusInputBox).toHaveBeenCalled();
          });
          it('should focus void the selecting state', function() {
            scope.multiple = false;
            scope.isSelecting = true;
            scope.handleInputBoxBlur();
            return expect(scope.isSelecting).toBe(false);
          });
          return it('should load default selections when there is no selection and there is default', function() {
            scope.selections.length = 0;
            spyOn(scope, 'loadDefaultSelections');
            scope.handleInputBoxBlur();
            return expect(scope.loadDefaultSelections).toHaveBeenCalled();
          });
        });
        describe('#handleSearchStringChange', function() {
          it('should set the offset to 0', function() {
            scope.searchParams.offset = 20;
            scope.handleSearchStringChange();
            return expect(scope.searchParams.offset).toBe(0);
          });
          return it('should call fetch to fetch new data', function() {
            spyOn(scope, 'fetch');
            scope.handleSearchStringChange();
            return expect(scope.fetch).toHaveBeenCalled();
          });
        });
        describe('#blurInputBox', function() {
          return it('should blur the input box', function() {
            spyOn(scope, 'handleInputBoxBlur');
            scope.blurInputBox();
            $timeout.flush();
            return expect(scope.handleInputBoxBlur).toHaveBeenCalled();
          });
        });
        describe('#focusInputBox', function() {
          var mockClickEvent;
          mockClickEvent = {
            target: "<li class=\"angular-selector-selection\">\n	<span>abc</span>\n</li>"
          };
          it('should do nothing if we click on a option', inject(function($timeout) {
            var inputElement;
            inputElement = element.find('input')[0];
            spyOn(inputElement, 'focus');
            scope.focusInputBox(mockClickEvent);
            $timeout.flush();
            return expect(inputElement.focus).not.toHaveBeenCalled();
          }));
          it('should focus the inputbox when no click event passed in', function() {
            var inputElement;
            inputElement = element.find('input')[0];
            spyOn(inputElement, 'focus');
            scope.focusInputBox();
            $timeout.flush();
            return expect(inputElement.focus).toHaveBeenCalled();
          });
          return it('should void the isSelected state', function() {
            scope.isSelected = true;
            scope.focusInputBox();
            $timeout.flush();
            return expect(scope.isSelected).toBe(false);
          });
        });
        describe('#handleKeydownResponse', function() {
          it('should increse verticalIndex by 1 when click down arrow', function() {
            var mockKeyEvent;
            mockKeyEvent = {
              keyCode: rcAngularSelectorKeyboardEnum.DOWN_ARROW
            };
            scope.verticalIndex = -1;
            scope.handleKeydownResponse(mockKeyEvent);
            return expect(scope.verticalIndex).toBe(0);
          });
          it('should decrease verticalIndex by 1 when click up arrow', function() {
            var mockKeyEvent;
            mockKeyEvent = {
              keyCode: rcAngularSelectorKeyboardEnum.UP_ARROW
            };
            scope.verticalIndex = 0;
            scope.handleKeydownResponse(mockKeyEvent);
            return expect(scope.verticalIndex).toBe(-1);
          });
          it('should increse horizontalIndex by 1 when click left arrow', function() {
            var mockKeyEvent;
            mockKeyEvent = {
              keyCode: rcAngularSelectorKeyboardEnum.LEFT_ARROW
            };
            scope.horizontalIndex = 0;
            scope.handleKeydownResponse(mockKeyEvent);
            return expect(scope.horizontalIndex).toBe(-1);
          });
          return it('should decrease horizontalIndex by 1 when click right arrow', function() {
            var mockKeyEvent;
            mockKeyEvent = {
              keyCode: rcAngularSelectorKeyboardEnum.RIGHT_ARROW
            };
            scope.horizontalIndex = 0;
            scope.handleKeydownResponse(mockKeyEvent);
            return expect(scope.horizontalIndex).toBe(1);
          });
        });
        describe('#resetVerticalIndex', function() {
          return it('should reset the vertical index to given number', function() {
            scope.resetVerticalIndex(10);
            expect(scope.verticalIndex).toBe(10);
            scope.resetVerticalIndex();
            return expect(scope.verticalIndex).toBe(-1);
          });
        });
        describe('#handleMouseoverOnSearchResults', function() {
          return it('should reset the verticalIndex to current search result index', function() {
            scope.handleMouseoverOnSearchResults(10);
            return expect(scope.verticalIndex).toBe(10);
          });
        });
        describe('#resetInputBox', function() {
          return it('should reset the inputbox value to ""', function() {
            var inputElement;
            inputElement = element.find('input');
            inputElement.val('abc');
            scope.resetInputBox();
            return expect(inputElement.val()).toBe('');
          });
        });
        describe('#resetSearchParams', function() {
          return it('should reset the search params to user defaults', function() {
            scope.searchParams = {
              offset: mockSearchParams.offset + 100
            };
            scope.resetSearchParams();
            return expect(scope.searchParams.offset).toBe(mockSearchParams.offset);
          });
        });
        describe('#resetHasMore', function() {
          return it('should reset the hasMore state to true', function() {
            scope.hasMore = false;
            scope.resetHasMore();
            return expect(scope.hasMore).toBe(true);
          });
        });
        describe('#updateSearchParams', function() {
          return it('should update the searchParams with new offset and limit', function() {
            scope.searchParams = {
              offset: 20,
              limit: 20
            };
            scope.updateSearchParams({
              offset: 40
            });
            expect(scope.searchParams.offset).toBe(40);
            return expect(scope.searchParams.limit).toBe(20);
          });
        });
        describe('#validateSearchResult', function() {
          return it('should find out if the searchResult has id and text', function() {
            var fakeBadSearchResult;
            fakeBadSearchResult = {
              id: '123',
              name: 'john'
            };
            expect(scope.validateSearchResult(fakeBadSearchResult)).toBe(false);
            fakeBadSearchResult = {
              _id: '123',
              text: 'john'
            };
            expect(scope.validateSearchResult(fakeBadSearchResult)).toBe(false);
            fakeBadSearchResult = {
              __id: '123',
              __text: 'john'
            };
            return expect(scope.validateSearchResult(fakeBadSearchResult)).toBe(true);
          });
        });
        describe('watch searchParams.searchString', function() {
          return it('should call #handleSearchStringChange', function() {});
        });
        return describe('watch selections.length', function() {
          return it('should set the horizontalIndex by selection length - 1', function() {
            scope.selections = [
              {
                'id': '123',
                'text': 'my mock data'
              }
            ];
            scope.horizontalIndex = scope.selections.length + 100;
            scope.$digest();
            return expect(scope.horizontalIndex).toBe(scope.selections.length - 1);
          });
        });
      });
    });
  });

}).call(this);
