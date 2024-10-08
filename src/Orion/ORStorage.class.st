Class {
	#name : 'ORStorage',
	#superclass : 'MooseGroupStorage',
	#type : 'variable',
	#instVars : [
		'model',
		'sortedCollectionList'
	],
	#category : 'Orion-Core',
	#package : 'Orion',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
ORStorage class >> new [ 
	 
	^self basicNew initialize: 10
]

{ #category : 'adding' }
ORStorage >> add: anElement [

	| key group |

	key := anElement class.
	group := byType at: key ifAbsentPut: [ OrderedCollection new ].
	group add: anElement.
	elements add: (anElement mooseID -> anElement).

	^ anElement
]

{ #category : 'accessing' }
ORStorage >> at: key [ 
	"Answer the value associated with the key."

	^ self atID: key ifAbsent: [self errorKeyNotFound]
]

{ #category : 'accessing' }
ORStorage >> at: uniqueName ifAbsent: exceptionBlock [

	| entity na |

	na := uniqueName asSymbol.
	entity := byName at: na ifAbsent: nil.
	entity
		ifNotNil: [ ^ (self atID: entity mooseID ifAbsent: [  ])
				versionLookup: self model ].
	entity := self
		detect: [ :each | na == (each versionLookup: self model) mooseName asSymbol ]
		ifNone: exceptionBlock.
	entity ifNotNil: [ byName at: na put: entity ].

	^entity versionLookup: self model
]

{ #category : 'accessing' }
ORStorage >> at: uniqueName withType: aType ifAbsent: exceptionBlock [
	| entity na |
	na := uniqueName asSymbol.
	entity := super at: uniqueName ifAbsent: [ nil ].
	entity ifNotNil: [
		^ (self atID: entity mooseID ifAbsent: [  ]) versionLookup: self model].

	entity := (self
		shouldSort: (self selectAllWithType: aType)
		withBlock: [ :a :b | a mooseName asSymbol <= b mooseName asSymbol ]
		type: aType
		modelVersion: self model)
		findBinary: [ :a | 
			| aName |
			aName := a mooseName asSymbol.
			aName = na
				ifTrue: [ 0 ]
				ifFalse: [ na < aName
						ifTrue: [ -1 ]
						ifFalse: [ 1 ] ] ]
		ifNone: exceptionBlock.
	entity ifNotNil: [ byName at: na put: entity ].

	^ entity versionLookup: self model
]

{ #category : 'accessing' }
ORStorage >> atID: anInteger ifAbsent: exceptionBlock [

	^elements at: anInteger ifAbsent: exceptionBlock
]

{ #category : 'private' }
ORStorage >> errorKeyNotFound [
	self error: 'key not found'
]

{ #category : 'initialize-release' }
ORStorage >> initialize: capacity [ 
	 
	byType := Dictionary new: 24.
	sortedCollectionList := Dictionary new: 24.
	byName := IdentityDictionary new: capacity.
	elements := HashTable new: capacity
]

{ #category : 'testing' }
ORStorage >> isOrion [

	^true
]

{ #category : 'accessing' }
ORStorage >> model [
	^ model
]

{ #category : 'accessing' }
ORStorage >> model: anObject [
	model := anObject
]

{ #category : 'removing' }
ORStorage >> remove: anElement ifAbsent: exceptionBlock [

	self updateCacheOnRemovalOf: anElement.
	elements removeKey: anElement mooseID ifAbsent: exceptionBlock.

	^ anElement
]

{ #category : 'private' }
ORStorage >> shouldSort: aCollection withBlock: aBlockClosure type: aMooseClass modelVersion: anORModel [

	"| isSorted modelVersionDict |

	modelVersionDict := self sortedCollectionList at: anORModel ifAbsentPut: [ Dictionary new ].
	isSorted := modelVersionDict at: aMooseClass ifAbsentPut: [ false ].
	^ isSorted
		ifTrue: [ aCollection ]
		ifFalse: [ modelVersionDict at: aMooseClass put: true.
			aCollection sort: aBlockClosure ]"
]

{ #category : 'accessing' }
ORStorage >> sortedCollectionList [
	^ sortedCollectionList ifNil: [ sortedCollectionList := Dictionary new ]
]

{ #category : 'private' }
ORStorage >> updateCacheOnAddingOf: anElement [

	"| key group |

	key := anElement class.
	group := byType at: key ifAbsentPut: [ self class byTypeDefaultCollection ].
	group add: anElement.
	(self sortedCollectionList at: anElement model privateState currentContext ifAbsentPut: [ Dictionary new ]) at: key put: false.
	anElement hasUniqueMooseNameInModel
		ifTrue: [ byName at: anElement mooseName asSymbol put: anElement ].
	^ anElement"
]
