/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.framework.test;

import java.util.HashMap;
import java.util.Map;

import com.google.apphosting.api.ApiProxy;

public class SimpleAppEngineTestEnvironment implements ApiProxy.Environment {

	@Override
	public String getAppId() {
        return "test";
    }

	@Override
    public String getVersionId() {
        return "1.0";
    }

	@Override
    public String getEmail() {
        return "foo.bar@gmail.com";
    }

	@Override
    public boolean isLoggedIn() {
        return true;
    }

	@Override
    public boolean isAdmin() {
        return false;
    }

	@Override
    public String getAuthDomain() {
        return "test";
    }

	@Override
	@SuppressWarnings("deprecation")
    public String getRequestNamespace() {
        return "";
    }

	@Override
    public Map<String, Object> getAttributes() {
        return new HashMap<String, Object>();
    }

	@Override
	public long getRemainingMillis() {
		return 0;
	}
}