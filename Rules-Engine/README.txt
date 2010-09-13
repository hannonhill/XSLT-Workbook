Dynamic Asset Assignment with Rules Engines

1. Metadata - Make a Metadata Set

Set Display Name to inline
Create a new text field called "rule" with a visible name of "Rule"

2. Asset Factory - Create an Asset Factory

Create a base file
Attach the Metadata to the file
Create an Asset Factory of type file that is set to use the base file 
and store the new files in /images/headers/ or another appropriate folder

3. Index Block - Create an Index Block

Create an index block that will index the /images/headers/ folder
index files
Indexed Asset Content (Regular Content, System Metadata, UserMetadata, Append Calling Page Data)

4. XSLT - Modify the XSLT

Change the output section of the template that has match="/"
so that it meets your needs

5. Template - Assign the Index Block and the XSLT Format to the right Template or Configuration Set

6. Image - Create some assets and Test
