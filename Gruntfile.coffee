module.exports = (grunt) ->

	[
		'grunt-contrib-clean'
		'grunt-contrib-coffee'
		'grunt-contrib-concat'
		'grunt-contrib-jasmine'
		'grunt-contrib-jshint'
		'grunt-contrib-sass'
		'grunt-contrib-watch'
		'grunt-express-server'
		'grunt-html2js'
		'grunt-autoprefixer'
		'grunt-browserify'
		'grunt-contrib-uglify'
		'grunt-contrib-cssmin'
		'grunt-contrib-copy'
	]
	.forEach grunt.loadNpmTasks

	# task sets
	build = ['clean:pre', 'jshint', 'test', 'sass:dev', 'autoprefixer']
	test = ['html2js', 'browserify', 'coffee:unit', 'jasmine:unit']
	run = ['build', 'express:dev', 'watch']
	server = ['express:dev', 'watch']
	release = ['build', 'uglify', 'cssmin']

	# task defs
	grunt.initConfig

		pkg: grunt.file.readJSON 'package.json'

		clean:
			pre: [
				'build'
			]

		coffee:
			unit:
				files:
					'test/unit.js': 'test/unit.coffee'

		concat:
			main:
				src: ['./src/angular-selector.js', './dist/template.js']
				dest: './dist/angular-selector.js'

		copy:
			font:
				files: [{
					expand: true
					cwd: 'bower_components/turn-icon-font/dist'
					src: 'turn-icon-font*'
					dest: 'static/turn-icon-font/'
				}]
					
		coveralls:
			options:
				force: true
			main:
				src: 'reports/lcov/lcov.info'

		html2js:
			main:
				src: './src/html/*.html'
				dest: './build/template-build.js'
			options:
				base: './src/html'
				module: 'angularSelectorTemplate'

		jasmine:
			unit:
				src: './build/angular-selector.js'
				options:
					specs: './test/unit.js'
					vendor: [
						'./bower_components/angular/angular.js'
						'./bower_components/angular-mocks/angular-mocks.js'
						'./bower_components/infinite-scroll-container/dist/infinite-scroll.js'
						'./bower_components/spin.js/spin.js'
						'./bower_components/angular-spinner/angular-spinner.js'
						'./node_modules/lodash/lodash.js'
					]
					keepRunner: true

		ngmin:
			main:
				src: ['./dist/angular-selector.js']
				dest: './dist/angular-selector.js'

		autoprefixer: 
			options: 
				browsers: [
					'Explorer >= 9',
					'last 5 Chrome versions'
					'last 5 Firefox versions'
				]
				cascade: true
			main:
				src: 'build/angular-selector.css'
				dest: 'build/angular-selector.css'

		sass:
			dev:
				files:
					'build/angular-selector.css': 'src/styles/angular-selector.scss'

		jshint:
			main:
				option:
					force: true
				files:
					src: ['src/js/*.js']

		browserify:
			dev:
				options:
					transform: ['browserify-ngannotate']
				files:
					'build/angular-selector.js': 'src/angular-selector.js'

		uglify:
			release:
				files:
					'dist/angular-selector.js': 'build/angular-selector.js'

		cssmin:
			release:
				files:
					'dist/angular-selector.css': 'build/angular-selector.css'

		watch:
			main:
				files: [
					'src/**/*'
					'./bower_components/*'
					'./node_modules/*'
				]
				tasks: build
				options:
					interrupt: true
					spawn: false
			test:
				files: './test/*.coffee'
				tasks: test
				options:
					interrupt: true
					spawn: false
			express:
				files: './server.js'
				tasks: ['express:dev']
				options:
					interrupt: true
					spawn: false
		
		express:
			dev:
				options:
					script: 'server.js'

	grunt.registerTask 'default', build
	grunt.registerTask 'build', build
	grunt.registerTask 'test', test
	grunt.registerTask 'run', run
	grunt.registerTask 'server', server
	grunt.registerTask 'release', release
