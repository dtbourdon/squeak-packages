"
A collection of class side messages to help with file system tasks.

"
Class {
	#name : #FileSystemTools,
	#superclass : #Object,
	#category : #'DTB-Tools'
}

{ #category : #utils }
FileSystemTools class >> cleanupFilenames: aDirectory dryRun: dryRun [
	"
	I cleanup files in the provided directory applying the following rulesrules: 
	
	1. Change all dashes and whitespace to underscores.
	2. Change multiple underscores to single underscores.
	3. Remove all non alphanumeric, slash or dot characters.
	4. Uppercase the characters.
	
	If dryRun is true the rename operations are performed, if not only a printout
	of what would be changed is shown.
	"

	(FileDirectory on: aDirectory) entriesDo: [ :entry |
		| oldFilename  newFilename newPath |
		
		entry isDirectory ifTrue: [
			self cleanupFilenames: entry fullName dryRun: dryRun.
		].
	
		oldFilename := entry fullName.
		newFilename := (entry baseName).
		
		self filenameCharacterMappings keysAndValuesDo: [ :key :value |
			newFilename := newFilename copyReplaceAll: key with: value
		].
		
		entry extension isEmpty ifFalse: [ newFilename := newFilename, '.', entry extension ].
		
		newFilename := newFilename asUppercase.
		newPath := aDirectory, '/', newFilename.
		
		(newPath = oldFilename) ifFalse: [		
			Transcript show: 'CONVERTING ', oldFilename; cr.
			Transcript show: '==> ', newPath; cr.
			
			dryRun ifFalse: [ (FileDirectory on: oldFilename) rename: oldFilename toBe: newPath ].
		]
	]
]

{ #category : #utils }
FileSystemTools class >> filenameCharacterMappings [
	"
	I return a dictionary of offending filename characters and their preferred mappings.
	I'm really designed to be referenced by the cleanupFilenames: dryRun: message.
	"

	| mappings |
	
	mappings := Dictionary new.
	
	mappings at: ' ' put: '_';
		at: '-' put: '_';
		at: '___' put: '_';
		at: '__' put: '_';
		at: '(' put: '';
		at: ')' put: '';
		at: ',' put: '';
		at: '&' put: 'AND';
		at: ($' asString) put: ''.
	
	^ mappings.
]
