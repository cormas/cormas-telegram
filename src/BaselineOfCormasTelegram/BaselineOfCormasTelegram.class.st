Class {
	#name : #BaselineOfCormasTelegram,
	#superclass : #BaselineOf,
	#category : #BaselineOfCormasTelegram
}

{ #category : #baselines }
BaselineOfCormasTelegram >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Dependencies"
		self loadCormas: spec.
		self loadBottlegram: spec.

		"Packages"
		spec
			package: 'Cormas-Telegram' with: [ spec requires: #(Cormas Bottlegram) ];
			package: 'Cormas-Telegram-Tests' with: [ spec requires: #( 'Cormas-Telegram' ) ] ]
]

{ #category : #dependencies }
BaselineOfCormasTelegram >> loadBottlegram: spec [

	spec
		baseline: 'Bottlegram'
		with: [ spec repository: 'github://pablo1n7/bottlegram' ]
]

{ #category : #dependencies }
BaselineOfCormasTelegram >> loadCormas: spec [

	spec
		baseline: 'Cormas'
		with: [ spec loads: #(Core); repository: 'github://cormas/cormas' ]
]
