Class {
	#name : #CormasBotSessionTest,
	#superclass : #TestCase,
	#instVars : [
		'session'
	],
	#category : #'Cormas-Telegram-Tests'
}

{ #category : #initialization }
CormasBotSessionTest >> setUp [

	super setUp.
	session := CormasBotSession new.
]

{ #category : #tests }
CormasBotSessionTest >> testId [

	self deny: session id isNil.
]
