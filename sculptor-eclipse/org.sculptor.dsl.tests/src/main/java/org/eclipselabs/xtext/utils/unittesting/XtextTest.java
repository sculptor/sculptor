package org.eclipselabs.xtext.utils.unittesting;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.antlr.runtime.ANTLRStringStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.Token;
import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.InternalEObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.mwe.utils.StandaloneSetup;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.GrammarUtil;
import org.eclipse.xtext.IGrammarAccess;
import org.eclipse.xtext.ParserRule;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.parser.IParser;
import org.eclipse.xtext.parser.antlr.ITokenDefProvider;
import org.eclipse.xtext.parser.antlr.Lexer;
import org.eclipse.xtext.parser.antlr.XtextTokenStream;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.SaveOptions;
import org.eclipse.xtext.resource.SaveOptions.Builder;
import org.eclipse.xtext.util.EmfFormatter;
import org.eclipse.xtext.util.Pair;
import org.eclipse.xtext.util.Tuples;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.Issue;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.BeforeAll;

import static org.junit.jupiter.api.Assertions.*;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

/**
 * <p>Base class for testing Xtext-based DSLs including validation, serialization, formatting, e.g.</p>
 * 
 * <p>{@see XtextTest} offers integration testing of model files (load, validate, serialize, compare)
 * as well as very specific unit-style testing for terminals, keywords and parser rules.</p>
 *
 * @author Karsten Thoms
 * @author Lars Corneliussen
 * @author Markus Voelter
 * @author Alexander Nittka
 * 
 */
public abstract class XtextTest {
    
	protected String resourceRoot;
	
	/* STATE for #testFile. TO BE initialized in #before */
	protected FluentIssueCollection issues;
	private Set<Issue> assertedIssues;
	private boolean compareSerializedModelToInputFile;
	private boolean invokeSerializer;
	private boolean formatOnSerialize;
	private boolean failOnParserWarnings;
	private boolean ignoreOsSpecificNewline;
	private EObject rootElement;
    /* END STATE for #testFile */
	
    private static Logger LOGGER = Logger.getLogger(XtextTest.class);
    
    @Inject
    protected ResourceSet resourceSet;
    
    @Inject
    private IResourceServiceProvider.Registry serviceProviderRegistry;
    
    @Inject
    private IGrammarAccess grammar;
    
    @Inject
    private IParser parser;
    
    @Inject
    private Lexer lexer;
    
    @Inject
    private ITokenDefProvider tokenDefProvider;
    
    public XtextTest() {
        this ("/");
    }

    public XtextTest(String resourceRoot) {
    	/* Classpath resuolution is weird
    	 * 
    	 * For resources directly in the classpath, you need a starting slash after 'classpath:/':
    	 *   - classpath://bla.txt
    	 *   
    	 * But if you wan't to point to something in a subfolder, the subfolder must
    	 * occur directly after 'classpath:/':
    	 *   - classpath://subfolder
    	 *   
    	 * A trailing slash is optional.
    	 * */
    	if (!resourceRoot.contains(":/")) {
    		this.resourceRoot = "classpath:/" + resourceRoot;
    	}
    	else {
    		this.resourceRoot = resourceRoot;
    	}
    }

    @BeforeAll
    public static void init_internal() {
        new StandaloneSetup().setPlatformUri("..");
    }

    @BeforeEach
    @Deprecated
    public void before() {}

    @BeforeEach
    public final void _before() {
    	issues = null;
    	assertedIssues = new HashSet<Issue>();
    	invokeSerializer = true;
    	compareSerializedModelToInputFile = true;
    	formatOnSerialize = true;
    	failOnParserWarnings = true;
    }
    
    private void ensureIsBeforeTestFile(){
    	if (issues != null) {
    		throw new RuntimeException("Method " + new Throwable().fillInStackTrace().getStackTrace()[1].getMethodName() + " must be run BEFORE 'testFile' is executed!");
    	}
    }
    
    private void ensureIsAfterTestFile(){
    	if (issues == null) {
    		throw new RuntimeException("Method " + new Throwable().fillInStackTrace().getStackTrace()[1].getMethodName() + " must be run AFTER 'testFile' is executed!");
    	}
    }
    
    @AfterEach
    @Deprecated
    public void after() {}

    @AfterEach
    public void _after() {
        if (issues != null) {
        	dumpUnassertedIssues();
        	if (issues.except(assertedIssues).getIssues().size() != 0) {
        		fail("\n\nfound unasserted issues " + issues.except(assertedIssues).getSummary() + "\n\n");
        	}
        }
    }
    
    protected EObject getModelRoot() {
    	return rootElement;
    }
    
    protected FluentIssueCollection testFile(String fileToTest, String... referencedResources) {
    	
		LOGGER.debug("testing " + fileToTest + " in test method " +this.getClass().getSimpleName() + "." + new Throwable().fillInStackTrace().getStackTrace()[1].getMethodName());
		
        for (String referencedResource : referencedResources) {
            URI uri = URI.createURI(resourceRoot + "/" + referencedResource);
            loadModel(resourceSet, uri, getRootObjectType(uri));
        }
        
        final Pair<String,FluentIssueCollection> result = loadAndSaveModule(resourceRoot, fileToTest);
        
        String serialized = result.getFirst();
        
        if (compareSerializedModelToInputFile) {
	        String expected = loadFileContents(resourceRoot, fileToTest);
	        if (ignoreOsSpecificNewline) {
	        	expected = expected.replaceAll("(\r\n|\r)", "\n");
	        	serialized = serialized.replaceAll("(\r\n|\r)", "\n");
	        }
	        // Remove trailing whitespace, see Bug#320074
	        // todo: Check if the trim really is still necessary!!
	        assertEquals(expected.trim(), serialized.trim());
        }
        
        return issues = result.getSecond();
    }
    
    protected FluentIssueCollection testFileNoSerializer( String fileToTest, String... referencedResources ) {
    	suppressSerialization();
        return testFile(fileToTest, referencedResources);
    }
    
    protected void testParserRule(String textToParse, String ruleName) {
        testParserRule(textToParse, ruleName, false);
    }

    private List<SyntaxErrorMessage> testParserRule(String textToParse, String ruleName,
            boolean errorsExpected) {
    	
    	ParserRule parserRule = (ParserRule) GrammarUtil.findRuleForName(grammar.getGrammar(), ruleName);
        
    	if (parserRule == null){
    		fail("\n\nCould not find ParserRule " + ruleName + "\n\n");
    	}
    	
    	IParseResult result = parser.parse(parserRule, new StringReader(textToParse));
        
        ArrayList<SyntaxErrorMessage> errors = Lists.newArrayList();
        ArrayList<String> errMsg = Lists.newArrayList();
        
        for (INode err : result.getSyntaxErrors()) {
        	errors.add(err.getSyntaxErrorMessage());
        	errMsg.add(err.getSyntaxErrorMessage().getMessage());
        }
        
        if (!errorsExpected && !errors.isEmpty()) {
            fail("\n\nParsing of text '" + textToParse + "' for rule '" + ruleName
                    + "' failed with errors: " + errMsg + "\n\n");
        }
        if (errorsExpected && errors.isEmpty()) {
            fail("\n\nParsing of text '" + textToParse + "' for rule '" + ruleName
                    + "' was expected to have parse errors.\n\n");
        }

        return errors;
    }

    protected void testParserRuleErrors(String textToParse, String ruleName, 
            String... expectedErrorSubstrings) {
        List<SyntaxErrorMessage> errors = testParserRule(textToParse, ruleName, true);
        
        Set<String> matchingSubstrings = new HashSet<String>();
        Set<String> assertedErrors = new HashSet<String>();
        
        boolean hadError = false;
        for(final SyntaxErrorMessage err : errors){
        	for(final String substring : expectedErrorSubstrings) {
        		boolean contains = err.getMessage().contains(substring);
            	if (contains) {
            		matchingSubstrings.add(substring);
            	}
        	}
        	
        	assertedErrors.add(err.getMessage());
        }
    
        StringBuilder error = new StringBuilder();
        if (expectedErrorSubstrings.length != matchingSubstrings.size()) {
        	error.append("Unmatched assertions:");
        	for (String string : expectedErrorSubstrings) {
				if (!matchingSubstrings.contains(string)){
					error.append("\n  - any error containing '" + string + "'");
				}
			}
        	error.append("\n");
        	hadError = true;
        }
        
        if (assertedErrors.size() != errors.size()) {
        	error.append("Unasserted Errors:");
        	for (SyntaxErrorMessage err : errors) {
				if (!assertedErrors.contains(err.getMessage())){
					error.append("\n  - " + err.getMessage());
				}
			}	
        }
        
        String failMessage = error.toString();
        if (hadError || (!failMessage.equals("") && failOnParserWarnings)) {
        	fail("\n\n" + failMessage + "\n\n");
        }
    }
    
     /**
     * return the list of tokens created by the lexer from the given input
     * */
    protected List<Token> getTokens(String input) {
      CharStream stream = new ANTLRStringStream(input);
      lexer.setCharStream(stream);
      XtextTokenStream tokenStream = new XtextTokenStream(lexer,
          tokenDefProvider);
      @SuppressWarnings("unchecked")
      List<Token> tokens = tokenStream.getTokens();
      return tokens;
    }

    /**
     * return the name of the terminal rule for a given token
     * */
    protected String getTokenType(Token token) {
      return tokenDefProvider.getTokenDefMap().get(token.getType());
    }

    /**
     * check whether an input is chopped into a list of expected token types
     * */
    protected void testTerminal(String input, String... expectedTerminals) {
      List<Token> tokens = getTokens(input);
      assertEquals(expectedTerminals.length, tokens.size(), input);
      for (int i = 0; i < tokens.size(); i++) {
        Token token = tokens.get(i);
        String exp = expectedTerminals[i];
        if (!exp.startsWith("'")) {
        	exp = "RULE_" + exp;
        }
        assertEquals(exp, getTokenType(token), input);
      }
    }

    /**
     * check that an input is not tokenised using a particular terminal rule
     * */
    protected void testNotTerminal(String input, String unexpectedTerminal) {
      List<Token> tokens = getTokens(input);
      Token token = tokens.get(0);
      
      assertNotSame(input, "RULE_" + unexpectedTerminal, getTokenType(token));
    }

     /**
     * check that input is treated as a keyword by the grammar
     * */
    protected void testKeyword(String input) {
      // the rule name for a keyword is usually
      // the keyword enclosed in single quotes
      String rule = new StringBuilder("'").append(input).append("'").toString();
      testTerminal(input, rule);
    }

    /**
     * check that input is not treated as a keyword by the grammar
     * */
    protected void testNoKeyword(String keyword) {
      List<Token> tokens = getTokens(keyword);
      assertEquals(1, tokens.size(), keyword);
      String type = getTokenType(tokens.get(0));
      assertFalse(type.charAt(0) == '\'', keyword);
    }
    

    protected String loadFileContents(String rootPath, String filename) {
        URI uri = URI.createURI(resourceRoot + "/" + filename);
        try {
            InputStream is = resourceSet.getURIConverter().createInputStream(uri);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            int i;
            while ((i = is.read()) >= 0) {
                bos.write(i);
            }
            is.close();
            bos.close();
            return bos.toString();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    protected Pair<String, FluentIssueCollection> loadAndSaveModule(String rootPath, String filename) {
        URI uri = URI.createURI(resourceRoot + "/" + filename);
        rootElement = loadModel(resourceSet, uri, getRootObjectType(uri));

        Resource r = resourceSet.getResource(uri, false);
        IResourceServiceProvider provider = serviceProviderRegistry
                .getResourceServiceProvider(r.getURI());
        List<Issue> result = provider.getResourceValidator().validate(r,
                CheckMode.ALL, null);

        if (invokeSerializer) {
	        ByteArrayOutputStream bos = new ByteArrayOutputStream();
	        try {
	        	Builder builder = SaveOptions.newBuilder();
	        	if (formatOnSerialize) {
	        		builder.format();
	        	}
				SaveOptions s = builder.getOptions();
	        	
				rootElement.eResource().save(bos, s.toOptionsMap());
	        } catch (IOException e) {
	            throw new RuntimeException(e);
	        }
	        
	        return Tuples.create(bos.toString(), new FluentIssueCollection(r, result, new ArrayList<String>()));
        } else {
        	return Tuples.create("-not serialized-", new FluentIssueCollection(r, result, new ArrayList<String>()));
        }
    }

    /**
     * Returns the expected type of the root element of the given resource.
     */
    protected Class<? extends EObject> getRootObjectType(URI uri) {
    	return null;
    }

    public void setResourceRoot(String resourceRoot) {
        this.resourceRoot = resourceRoot;
    }

    @SuppressWarnings("unchecked")
    protected <T extends EObject> T loadModel(ResourceSet rs, URI uri, Class<T> clazz) {
        Resource resource = rs.createResource(uri);
        try {
            resource.load(null);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        
        StringBuilder errors = new StringBuilder();
        if (!resource.getWarnings().isEmpty()) {
        	LOGGER.error("Resource " + uri.toString() + " has warnings:");
            for (Resource.Diagnostic issue : resource.getWarnings()) {
            	LOGGER.error(issue.getLine() + ": " + issue.getMessage());
            }
            if (failOnParserWarnings) {
	            errors.append("Resource as warnings:");
	            for (Resource.Diagnostic issue : resource.getWarnings()) {
	            	errors.append("\n  - " + issue.getLine() + ": " + issue.getMessage());
	            }
	            errors.append("/n");
            }
        }
        
        if (!resource.getErrors().isEmpty()) {
        	LOGGER.error("Resource " + uri.toString() + " has errors:");
            for (Resource.Diagnostic issue : resource.getErrors()) {
            	LOGGER.error("    " + issue.getLine() + ": " + issue.getMessage());
            }
            
            errors.append("Resource as errors:");
            for (Resource.Diagnostic issue : resource.getErrors()) {
            	errors.append("\n  - " + issue.getLine() + ": " + issue.getMessage());
            }
        }
        
        String failMessage = errors.toString();
        if (!failMessage.equals("")){
        	fail("\n\n" + failMessage + "\n");
        }

        assertFalse(resource.getContents().isEmpty(), "Resource has no content");
        EObject o = resource.getContents().get(0);
        // assure that the root element is of the expected type
        if (clazz != null) {
        	assertTrue(clazz.isInstance(o));
        }
        EcoreUtil.resolveAll(resource);
        return (T) o;
    }

    protected void assertAllCrossReferencesResolvable(EObject obj) {
        boolean allIsGood = true;
        TreeIterator<EObject> it = EcoreUtil2.eAll(obj);
        while (it.hasNext()) {
            EObject o = it.next();
            for (EObject cr : o.eCrossReferences())
                if (cr.eIsProxy()) {
                    allIsGood = false;
                    System.err.println("CrossReference from " + EmfFormatter.objPath(o) + " to "
                            + ((InternalEObject) cr).eProxyURI() + " not resolved.");
                }
        }
        if (!allIsGood) {
            fail("Unresolved cross references in " + EmfFormatter.objPath(obj));
        }
    }
    
    protected void resetAssertedIssues() {
		assertedIssues.clear();
	}
    
    /**
     * If called prior to #testFile, serialization will be performed, 
     * but the result is not expected to exactly match the input file.
     */
    protected void ignoreSerializationDifferences(){
    	ensureIsBeforeTestFile();
    	
    	compareSerializedModelToInputFile = false;
    }

    /**
     * If called prior to #testFile, serialization won't be performed.
     */
    protected void suppressSerialization(){
    	ensureIsBeforeTestFile();
    	
    	compareSerializedModelToInputFile = false;
    	invokeSerializer = false;
    }
    
    /**
     * If called prior to #testFile, parser warnings will be ignored.
     * Errors will still be reported, though.
     */
    protected void ignoreParserWarnings(){
    	ensureIsBeforeTestFile();
    	
    	failOnParserWarnings = false;
    }
    
    /**
     * Serialization will occur without formatting, hence the
     * input model must not comply to formatting rules in order
     * to succeed.
     */
    protected void ignoreFormattingDifferences(){
    	ensureIsBeforeTestFile();
    	
    	formatOnSerialize = false;
    }
    
    /**
     * If called after to #testFile, the test wont fail for unasserted warnings.
     */
    protected void ignoreUnassertedWarnings(){
    	ensureIsAfterTestFile();
    	
    	// just treat the warnings left as asserted
    	assertedIssues.addAll(issues.warningsOnly().except(assertedIssues).getIssues());
    }
	
	/**
	 * Text file comparison will ignore OS specific newlines by harmonizing expected and serialized
	 * text with Unix style newline.  
	 */
	protected void ignoreOsSpecificNewline() {
		this.ignoreOsSpecificNewline = true;
	}

	protected void assertConstraints( FluentIssueCollection coll, String msg ) {
		ensureIsAfterTestFile();
		
		assertedIssues.addAll(coll.getIssues());
		assertTrue(coll.evaluate(), "failed "+msg+coll.getMessageString());
	}
	
	protected void assertConstraints( FluentIssueCollection coll) {
		ensureIsAfterTestFile();
		
		assertedIssues.addAll(coll.getIssues());
		assertTrue(coll.evaluate(), "<no id> failed"+coll.getMessageString());
	}
	
	protected void assertConstraints( String constraintID, FluentIssueCollection coll) {
		ensureIsAfterTestFile();
		
		assertedIssues.addAll(coll.getIssues());
		assertTrue(coll.evaluate(), constraintID + " failed"+coll.getMessageString());
	}
	
	public EObject getEObject( URI uri ) {
		EObject eObject = issues.getResource().getEObject(uri.fragment());
		if ( eObject.eIsProxy()) {
			eObject = EcoreUtil.resolve(eObject, issues.getResource());
		}
		return eObject;
	}	
	
	private void dumpUnassertedIssues() {
		if ( issues.except(assertedIssues).getIssues().size() > 0 ) {
			LOGGER.warn("---- Unasserted Issues ----");
			for (Issue issue: issues.except(assertedIssues)) {
				FluentIssueCollection.dumpIssue( issues.getResource(), issue );
			}
		}
	}
}
