/**
 * Fiji script installing a QuPath extension (QuPath v0.3)
 * 
 * Yes it looks weird but it makes sense, because modifying QuPath jars from within QuPath creates issues:
 * jars files are in use, so they can't be deleted.
 * 
 * Also, QuPath uses Java user preferences, which can be easily accessed for any Java software (like Fiji!)
 * Thus, this script can look whether a QuPath user path is already defined, and adds the jars 
 * necessary for a QuPath extension into it.
 * 
 * If the preference of a QuPath user folder does not exist, it it created and will be recognized
 * when QuPath is installed
 * 
 * For this to work, the QuPath extension has to be accessible via downloading through a single URL
 * 
 * If the QuPath extension is a single jar, it is downloaded, no problem
 * If the QuPath extension consists of multiple jars, the URL has to point towards a zip file
 * the zip file should contains all jars dependencies in a flat hierarchy
 * 
 * This script keeps only the latest versions of installed jars BUT it will not remove jars
 * which have become useless / obsolete.
 * 
 * It will make this jar filtering and removal for all jars present in the user QuPath extension folder
 * 
 * Example of url extension which can be installed with this script:
 * 
 * BIOP extensions:
 * https://github.com/BIOP/qupath-extension-biop/releases/download/v1.0.2/qupath-extension-biop-1.0.2.jar
 * 
 * Warpy:
 * https://github.com/BIOP/qupath-extension-warpy/releases/download/0.2.0/qupath-extension-warpy-0.2.0.zip
 * 
 * ABBA:
 * https://github.com/BIOP/qupath-extension-abba/releases/download/0.1.1/qupath-extension-abba-0.1.1.zip
 * 
 * Cellpose:
 * https://github.com/BIOP/qupath-extension-cellpose/releases/download/v0.3.0/qupath-extension-cellpose-0.3.0.jar
 * 
 * Author: Nicolas Chiaruttini, BIOP, EPFL 2021
 **/ 

#@String(label="QuPath User Folder", value="C:/QuPath Common Data") defaultQuPathUserPath
#@String(label="QuPath Prefs Node", value="io.github.qupath/0.3") quPathPrefsNode
#@String(label="URL of QuPath Extension to install") quPathExtensionURL
#@Boolean(lable="Quit after installation") quitAfterInstall

IJ.log(defaultQuPathUserPath)
IJ.log(quPathPrefsNode)
IJ.log(quPathExtensionURL)

defaultQuPathUserPath = new File(defaultQuPathUserPath).getAbsolutePath() // avoid double slash issues

// Check pre-existing QuPath user Path
Preferences prefs = Preferences.userRoot().node(quPathPrefsNode);
def allKeys = prefs.keys() as List
println(allKeys.contains('userPath'))
def userPath = prefs.get("userPath", defaultQuPathUserPath)

if (userPath.equals(defaultQuPathUserPath)) {
	IJ.log("Setting java prefs because the pref may not exist")
	prefs.put("userPath", defaultQuPathUserPath)
} else {
	IJ.log("QuPath user path already exists")
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

// Create QuPath extensions folder if needed
File extensionsDir = new File(userPath,"extensions")
if (!extensionsDir.exists()) {
	def result = extensionsDir.mkdir()
	if (!result) {
		IJ.log("Could not create folder "+extensionsDir+". Exiting.")
		return
	}
}

// Copy file from URL to disk
def url = new URL(quPathExtensionURL)
String fName = FilenameUtils.getName(url.getPath())
String extension = FilenameUtils.getExtension(url.getPath())

def outputFile = new File(extensionsDir, fName)

IJ.log("Starting download")
FileUtils.copyURLToFile(url, outputFile);
IJ.log("Download done")

// Unzip file if necessary
if (extension.equals("zip")) {
	IJ.log("Unzipping extension")
	try (ZipFile zipFile = new ZipFile(outputFile)) {
	  Enumeration<? extends ZipEntry> entries = zipFile.entries();
	  while (entries.hasMoreElements()) {
	    ZipEntry entry = entries.nextElement();
	    File entryDestination = new File(extensionsDir,  entry.getName());
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

// Cleans old jars

// REGEX: (.+)-([0-9]+).([0-9]+)?.([0-9]+)?(-SNAPSHOT)?(\.jar) to get jars versions:
// name-0.1.0.jar if it doesn't match it's ignored
def pattern_expression = '(.+)-([0-9]+).([0-9]+)?.([0-9]+)?(-SNAPSHOT)?(\\.jar)'
Pattern pattern = Pattern.compile(pattern_expression);

Map<String, RepoAndVersion> jarsMaxVersion = new HashMap();
listJars(extensionsDir.getAbsolutePath())
	.stream()
	.each{it -> 
			IJ.log(it.toString())
			Matcher matcher = pattern.matcher(it.toString());
			if (matcher.find()) {
	            def v1 = new RepoAndVersion(it.toString(),
	            	matcher.group(1), 
	            	matcher.group(2), 
	            	matcher.group(3), 
	            	matcher.group(4), 
	            	matcher.group(5)!=null)

				if (jarsMaxVersion.containsKey(v1.repoName)) {
					// Fight : who has a higher version ?
					def v2 = jarsMaxVersion.get(v1.repoName)
					if (v1.hasHigherVersionThan(v2)) {
						// Swap the map
						jarsMaxVersion.put(v1.repoName, v1)
						// Delete v2, because v1>v2
						def result = new File(extensionsDir, v2.fileName).delete()
						if (!result) IJ.log("Delete failed! Do you have QuPath opened ? Please close it before installing the extension")
						IJ.log("Found duplicated jars, deleting older version "+v2.fileName)
					} else {
						// Delete v1, because v2>v1
						def result = new File(extensionsDir, v1.fileName).delete()
						if (!result) IJ.log("Delete failed! Do you have QuPath opened ? Please close it before installing the extension")
						IJ.log("Found duplicated jars, deleting older version "+v1.fileName)
					}
				} else {
					// No Fight
					jarsMaxVersion.put(v1.repoName, v1)
				}
        	}
		}

if (quitAfterInstall) {
	IJ.run("Quit");
}

"Done"

// List all files ending with jar
public Set listJars(String dir) throws IOException {
    try (Stream stream = Files.list(Paths.get(dir))) {
        return stream
          .filter(file -> !Files.isDirectory(file))
          .map(it -> it.getFileName())
          .map(it -> it.toString())
          .filter(it -> it.endsWith(".jar"))
          .collect(Collectors.toSet());
    }
}

class RepoAndVersion {

	int major
	int minor = -1
	int patch = -1
	boolean snapshot
	String fileName
	String repoName
	
	public RepoAndVersion(String fileName, String repoName, String major, String minor, String patch, boolean snapshot) {
		this.fileName = fileName
		this.repoName = repoName
		this.major = Integer.valueOf(major)
		if (minor!=null) this.minor = Integer.valueOf(minor)
		if (patch!=null) this.patch = Integer.valueOf(patch)
		this.snapshot = snapshot
	}

	public boolean hasHigherVersionThan(RepoAndVersion other) {
		/*IJ.log("M:"+major+" vs "+other.major)
		IJ.log("m:"+minor+" vs "+other.minor)
		IJ.log("p:"+patch+" vs "+other.patch)
		IJ.log("s:"+snapshot+" vs "+other.snapshot)*/
		if (major > other.major) {
			return true;
		}
		if (major < other.major) {
			return false;
		}
		assert major == other.major
		if (minor > other.minor) {
			return true;
		}
		if (minor < other.minor) {
			return false;
		}
		assert minor == other.minor
		if (patch > other.patch) {
			return true;
		}
		if (patch < other.patch) {
			return false;
		}
		assert patch == other.patch
		if ((snapshot)&&(!other.snapshot)) { // 'this' is snapshot, other is not -> return false
			return false
		}
		if ((!snapshot)&&(other.snapshot)) { // 'this' is not snapshot, other is-> return true
			return true
		}
		// Equal versions... should not happen, because files are erased
		IJ.error("Is "+fileName+" not identical to "+other.fileName+"?")
		return false // nonetheless
	}
}

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
