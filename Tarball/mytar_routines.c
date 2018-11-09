#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "mytar.h"

extern char *use;

/** Copy nBytes bytes from the origin file to the destination file.
 *
 * origin: pointer to the FILE descriptor associated with the origin file
 * destination:  pointer to the FILE descriptor associated with the destination file
 * nBytes: number of bytes to copy
 *
 * Returns the number of bytes actually copied or -1 if an error occured.
 */
 static int copynFile(FILE * origin, FILE * destination, unsigned int nBytes)
{
	/**
	* cont: number of "getc" function calls, should match with nBytes
	* c: int value to cats as a unsigned char on the "putc" function
	*/
	int c, cont = 0;

	while ((cont < nBytes) && ((c = getc(origin)) != EOF)){
		putc(c, destination);
		cont++;
	}
	return cont;
}

/** Loads a string from a file.
 *
 * file: pointer to the FILE descriptor 
 * 
 * The loadstr() function must allocate memory from the heap to store 
 * the contents of the string read from the FILE. 
 * Once the string has been properly built in memory, the function returns
 * the starting address of the string (pointer returned by malloc()) 
 * 
 * Returns: !=NULL if success, NULL if error
 */
static char* loadstr(FILE * file)
{
	char *str;
	int i = 0, c;
	
	if((str = (char *)malloc(PATH_MAX * sizeof(char)))  == NULL){
		perror("cannot allocate file name on memory");
		return NULL;
	}
	do{
		c = getc(file);
		str[i]= (char)c;
		i++;

	}while((c != EOF)&&((char)c != '\0'));
	str[i] = '\0';

	return str;
}

/** Read tarball header and store it in memory.
 *
 * tarFile: pointer to the tarball's FILE descriptor 
 * nFiles: output parameter. Used to return the number 
 * of files stored in the tarball archive (first 4 bytes of the header).
 *
 * On success it returns the starting memory address of an array that stores 
 * the (name,size) pairs read from the tar file. Upon failure, the function returns NULL.
 */
static stHeaderEntry* readHeader(FILE * tarFile, unsigned int *nFiles)
{
	//header to return
	stHeaderEntry* header = NULL;
	int i,j;

	//read the number of files inside the mytar file
	fread(nFiles,sizeof (int), 1,tarFile);

	//tryto alocate memory for header, NULL if fail
	header = malloc(sizeof(stHeaderEntry)* (*nFiles));
	//control de errores
	if(header == NULL){
		perror("Uopss! This mtar is too big to be alocated in memory");
		fclose(tarFile);
	}
	//alocate header information
	else{
		for(i = 0; i < *nFiles; i++){
			//error control
			if((header[i].name = loadstr(tarFile)) == NULL){
				for(j = 0; j < i; j++)
					free(header[j].name);
				fclose(tarFile);
				return NULL;
			}
			fread(&header[i].size, sizeof(unsigned int), 1, tarFile);
		}
	}
	return header;
}

/** Creates a tarball archive 
 *
 * nfiles: number of files to be stored in the tarball
 * filenames: array with the path names of the files to be included in the tarball
 * tarname: name of the tarball archive
 * 
 * On success, it returns EXIT_SUCCESS; upon error it returns EXIT_FAILURE. 
 * (macros defined in stdlib.h).
 *
 * HINTS: First reserve room in the file to store the tarball header.
 * Move the file's position indicator to the data section (skip the header)
 * and dump the contents of the source files (one by one) in the tarball archive. 
 * At the same time, build the representation of the tarball header in memory.
 * Finally, rewind the file's position indicator, write the number of files as well as 
 * the (file name,file size) pairs in the tar archive.
 *
 * Important reminder: to calculate the room needed for the header, a simple sizeof 
 * of stHeaderEntry will not work. Bear in mind that, on disk, file names found in (name,size) 
 * pairs occupy strlen(name)+1 bytes.
 *
 */
int createTar(int nFiles, char *fileNames[], char tarName[])
{

	FILE *tarFile, *in;
	int i, headerSize = 0;

	//Allocate header
	stHeaderEntry *header = malloc(sizeof(stHeaderEntry) * nFiles );
	if(header == NULL){
		perror("Cannot allocate header tar file in memory");
		return EXIT_FAILURE;
	}
	
	//create tar file
	if((tarFile = fopen(tarName, "w")) == NULL){
		perror("Cannot create the tar file");
		return EXIT_FAILURE;
	}
	
	//calculate header size in memory
	for(i = 0; i < nFiles; i++)
		headerSize = headerSize + strlen(fileNames[i]) + 1;

	headerSize = sizeof(char) * headerSize + sizeof(int) + nFiles * sizeof(unsigned int);

	//pointer to header end
	fseek(tarFile, headerSize, SEEK_SET);

	for(i = 0; i < nFiles; i++){
		//allocate name file in memory
		header[i].name = (char*) malloc(strlen(fileNames[i]) + 1);
		//open FILE
		if((in = fopen(fileNames[i], "r")) == NULL){
			free(header);
			fclose(tarFile);
			return EXIT_FAILURE;
		}
		//copy name file to include in the tar
		strcpy(header[i].name, fileNames[i]);
		//copy file data using copynFile method
		header[i].size = copynFile(in, tarFile, INT_MAX);
		//close FILE
		fclose(in);
	}
	//at this point is needed to move the pointer to the begining to write th header
	rewind(tarFile);
	//write the number of files to include in the tar
	fwrite(&nFiles, sizeof(int), 1, tarFile);
	//write the header information
	for(i = 0; i < nFiles; ++i){
		fwrite(header[i].name, sizeof(char), strlen(fileNames[i]), tarFile);
		putc('\0', tarFile);
		fwrite(&header[i].size, sizeof(unsigned int), 1, tarFile);
	}
	//free memory and close FILE
	free(header);
	fclose(tarFile);
	fprintf(stdout, "Mtar created successfuly\n");

	return EXIT_SUCCESS;
}

/** Extract files stored in a tarball archive
 *
 * tarName: tarball's pathname
 *
 * On success, it returns EXIT_SUCCESS; upon error it returns EXIT_FAILURE. 
 * (macros defined in stdlib.h).
 *
 * HINTS: First load the tarball's header into memory.
 * After reading the header, the file position indicator will be located at the 
 * tarball's data section. By using information from the 
 * header --number of files and (file name, file size) pairs--, extract files 
 * stored in the data section of the tarball.
 *
 */
int extractTar(char tarName[])
{
	stHeaderEntry *header;
	FILE *tarFile, *output;
	unsigned int nFiles;
	int i;


	//open tar file
	if((tarFile = fopen(tarName, "r")) == NULL){
		perror("Cannot open the tar file");
		return EXIT_FAILURE;
	}

	//create the header
	header = readHeader(tarFile, &nFiles);
	//create and write the files with the contain information
	for(i = 0; i < nFiles; i++){
		
		output = fopen(header[i].name, "w");
		copynFile(tarFile,output, header[i].size);
		fprintf(stdout, "Creating File %s, size %d Bytes...OK\n", header[i].name, header[i].size);
		fclose(output);
		
	}

	fprintf(stdout, "Extracted\n");
	//free memory and close FILE
	free(header);
	fclose(tarFile);


	return EXIT_SUCCESS;
	
}


