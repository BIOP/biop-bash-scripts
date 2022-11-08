/**
 * Fiji script installing the content of a repo as shared scripts in QuPath v0.3
 * 
 * QuPath uses Java user preferences, which can be easily accessed for any Java software (like Fiji!)
 * Thus, this script can look whether a QuPath user path is already defined, and adds the jars 
 * necessary for a QuPath extension into it.
 * 
 * If the preference of a QuPath user folder does not exist, it it created and will be recognized
 * when QuPath is installed
 * 
 * For this to work, the QuPath scripts have to be accessible via downloading through a single URL,
 * pointing to a zip file
 * 
 * Existing scripts will be overriden, but no obsolete script will be actively removed
 * 
 * Example of url scripts which can be installed with this script:
 * 
 * 
 * https://github.com/BIOP/qupath-scripts/archive/refs/heads/main.zip
 * 
 * Which is the latest state of the main branch of https://github.com/BIOP/qupath-scripts
 * 
 * Author: Nicolas Chiaruttini, BIOP, EPFL 2022
 **/ 

#@String(label="QuPath User Folder", value="C:/QuPath Common Data") defaultQuPathUserPath
#@String(label="QuPath Prefs Node", value="io.github.qupath/0.3") quPathPrefsNode
#@String(label="URL of QuPath Scripts Repo to install") quPathScriptsURL
#@Boolean(lable="Quit after installation") quitAfterInstall

IJ.log(defaultQuPathUserPath)
IJ.log(quPathPrefsNode)
IJ.log(quPathScriptsURL)

defaultQuPathUserPath = new File(defaultQuPathUserPath).getAbsolutePath() // avoid double slash issues

// Check pre-existing QuPath user Path
Preferences prefs = Preferences.userRoot().node(quPathPrefsNode);
def allKeys = prefs.keys() as List
println(allKeys.contains('userPath'))
def userPath = prefs.get("userPath", defaultQuPathUserPath)

if (userPath.equals(defaultQuPathUserPath)) {
	IJ.log("Setting java prefs because the pref may not exist")
	prefs.put("userPath", defaultQuPathUserPath)
	prefs.put("scriptsPath", defaultQuPathUserPath+"/qupath-scripts")
} else {
	IJ.log("QuPath user path already exists")
	prefs.put("scriptsPath", defaultQuPathUserPath+"/qupath-scripts")
}

IJ.log("QuPath user path: "+userPath)

// Create QuPath user folder if needed
File userPathFile = new File(userPath)
if (!userPathFile.exists()) {
	def result = userPathFile.mkdir()
	if (!result) {
		IJ.log("Could not create folder "+userPath+". Exiting.")
		return
	}
}

// Create QuPath scripts folder if needed
File scriptsDir = new File(userPath,"qupath-scripts")
if (!scriptsDir.exists()) {
	def result = scriptsDir.mkdir()
	if (!result) {
		IJ.log("Could not create folder "+scriptsDir+". Exiting.")
		return
	}
}

// Copy file from URL to disk
def url = new URL(quPathScriptsURL)
String fName = FilenameUtils.getName(url.getPath())
String extension = FilenameUtils.getExtension(url.getPath())

def outputFile = new File(scriptsDir, fName)

IJ.log("Starting download")
FileUtils.copyURLToFile(url, outputFile);
IJ.log("Download done")

// Unzip file if necessary
if (extension.equals("zip")) {
	IJ.log("Unzipping")
	try (ZipFile zipFile = new ZipFile(outputFile)) {
	  Enumeration<? extends ZipEntry> entries = zipFile.entries();
	  while (entries.hasMoreElements()) {
	    ZipEntry entry = entries.nextElement();
	    // IJ.log(entry.getName())
	    // Remove the first subfolder: convenient for extracting a github repo
	    String entryOneLessFolder = entry.getName().substring(entry.getName().indexOf('/'), entry.getName().size());
	    File entryDestination = new File(scriptsDir,  entryOneLessFolder);
	    if (entry.isDirectory()) {
	        entryDestination.mkdirs();
	    } else {
	        entryDestination.getParentFile().mkdirs();
	        try (InputStream in = zipFile.getInputStream(entry);
	             OutputStream out = new FileOutputStream(entryDestination)) {
	             IOUtils.copy(in, out);
	        }
	    }
	  }
	}
	IJ.log("Unzipping done")
	outputFile.delete()
}

if (quitAfterInstall) {
	IJ.run("Quit");
}

"Done"

import java.util.regex.Pattern
import java.util.regex.Matcher
import java.util.prefs.Preferences
import ij.IJ
import java.io.File
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.IOUtils
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.stream.Stream
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.Path
import java.util.stream.Collectors
