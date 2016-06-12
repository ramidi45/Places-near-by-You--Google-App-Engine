package google.app.engine;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.Multipart;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

@SuppressWarnings("serial")
public class GoogleapiServlet extends HttpServlet {
	UserService userService = UserServiceFactory.getUserService();
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
		String thisURL = req.getRequestURI();

		resp.setContentType("text/html");
		if (req.getUserPrincipal() != null) {
			req.setAttribute("logininfo", "<p>Hello, " +
					userService.getCurrentUser().getNickname() +
					"!  You can <a href=\"" +
					userService.createLogoutURL(thisURL) +
					"\">sign out</a>.</p>");
		
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
			dispatcher.forward(req, resp);    
		} else {
			resp.getWriter().println("<p>Please <a href=\"" +
					userService.createLoginURL(thisURL) +
					"\">sign in</a>.</p>");

		}

	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
		Properties props = new Properties();
		Session session = Session.getDefaultInstance(props, null);
		
		req.setAttribute("logininfo", "<p>Hello, " +
				userService.getCurrentUser().getNickname() +
				"! </p>");
		try {
		String sendaddress = req.getParameter("toadrress").toString();
		String sub = "ProjectP2: Know Your Location";
		Multipart mp = new MimeMultipart();
        MimeBodyPart htmlPart = new MimeBodyPart();
        htmlPart.setContent(req.getParameter("weather"), "text/html");
        mp.addBodyPart(htmlPart);
        
		    Message msg = new MimeMessage(session);
		    msg.setFrom(new InternetAddress(req.getUserPrincipal().getName(), "Cloud ProjectP2 Admin"));
		    msg.addRecipient(Message.RecipientType.TO,
		                     new InternetAddress(sendaddress, "Mr/Mrs "+ sendaddress));
		    msg.setSubject(sub);
		    msg.setContent(mp);
		    Transport.send(msg);
		    
		} 
		catch (AddressException e) {
		    System.out.println("invalid email "+e);
		} catch (MessagingException e)
		{
		    System.out.println("invalid message "+e);
		}
		 catch (Exception e)
		{
		    System.out.println("exception "+e);
		}
		RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
		dispatcher.forward(req, resp);    
	}
}
