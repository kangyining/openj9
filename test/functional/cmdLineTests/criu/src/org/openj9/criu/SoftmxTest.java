/*******************************************************************************
 * Copyright IBM Corp. and others 2023
 *
 * This program and the accompanying materials are made available under
 * the terms of the Eclipse Public License 2.0 which accompanies this
 * distribution and is available at https://www.eclipse.org/legal/epl-2.0/
 * or the Apache License, Version 2.0 which accompanies this distribution and
 * is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * This Source Code may also be made available under the following
 * Secondary Licenses when the conditions for such availability set
 * forth in the Eclipse Public License, v. 2.0 are satisfied: GNU
 * General Public License, version 2 with the GNU Classpath
 * Exception [1] and GNU General Public License, version 2 with the
 * OpenJDK Assembly Exception [2].
 *
 * [1] https://www.gnu.org/software/classpath/license.html
 * [2] https://openjdk.org/legal/assembly-exception.html
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0 OR GPL-2.0-only WITH Classpath-exception-2.0 OR GPL-2.0-only WITH OpenJDK-assembly-exception-1.0
 *******************************************************************************/
package org.openj9.criu;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

import org.eclipse.openj9.criu.*;

public class SoftmxTest {
	public static void main(String[] args) {
		String test = args[0];

		switch (test) {
		case "PropertiesTest1":
			propertiesTest1();
			break;
		default:
			throw new RuntimeException("incorrect parameters");
		}

	}

	static void propertiesTest1() {
		String optionsContents = "-Dprop1=val1\n-Dprop2=val2\n-Dprop3=val3";
		Path optionsFilePath = CRIUTestUtils.createOptionsFile("options", optionsContents);

		Path imagePath = Paths.get("cpData");
		CRIUTestUtils.createCheckpointDirectory(imagePath);
		CRIUSupport criuSupport = new CRIUSupport(imagePath);
		criuSupport.registerRestoreOptionsFile(optionsFilePath);

		System.out.println("Pre-checkpoint");
		CRIUTestUtils.checkPointJVM(criuSupport, imagePath, true);
		System.out.println("Post-checkpoint");

		if (!System.getProperty("prop1").equalsIgnoreCase("val1")) {
			System.out.println("ERR: failed properties test");
		}

		if (!System.getProperty("prop2").equalsIgnoreCase("val2")) {
			System.out.println("ERR: failed properties test");
		}

		if (!System.getProperty("prop3").equalsIgnoreCase("val3")) {
			System.out.println("ERR: failed properties test");
		}
	}

}
