/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.apio.architect.internal.jaxrs.util;

import static com.liferay.apio.architect.internal.writer.ErrorWriter.writeError;

import static java.lang.String.join;

import static org.slf4j.LoggerFactory.getLogger;

import com.liferay.apio.architect.error.APIError;
import com.liferay.apio.architect.internal.message.json.ErrorMessageMapper;
import com.liferay.apio.architect.internal.wiring.osgi.manager.exception.mapper.ExceptionMapperManager;
import com.liferay.apio.architect.internal.wiring.osgi.manager.message.json.ErrorMessageMapperManager;

import java.util.Optional;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Request;
import javax.ws.rs.core.Response;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import org.slf4j.Logger;

/**
 * Provides utility methods for transforming exceptions into responses.
 *
 * @author Alejandro Hernández
 */
@Component(service = ErrorUtil.class)
public class ErrorUtil {

	/**
	 * Transforms an exception into a {@code Response}.
	 *
	 * @param  e the exception
	 * @param  request the current request
	 * @return the response
	 */
	public <E extends Throwable> Response getErrorResponse(
		E e, Request request) {

		if (!Exception.class.isAssignableFrom(e.getClass())) {
			_logException(e, e.getMessage());

			return _serverError;
		}

		Optional<APIError> apiErrorOptional = _exceptionMapperManager.map(
			(Exception)e);

		if (!apiErrorOptional.isPresent()) {
			_logger.warn("No exception mapper found for {}", e.getClass());

			_logException(e, e.getMessage());

			if (e instanceof WebApplicationException) {
				WebApplicationException webApplicationException =
					(WebApplicationException)e;

				return webApplicationException.getResponse();
			}

			return _serverError;
		}

		APIError apiError = apiErrorOptional.get();

		_logException(e, apiError.getMessage());

		int statusCode = apiError.getStatusCode();

		Optional<ErrorMessageMapper> errorMessageMapperOptional =
			_errorMessageMapperManager.getErrorMessageMapperOptional(request);

		return errorMessageMapperOptional.map(
			errorMessageMapper -> Response.status(
				statusCode
			).type(
				errorMessageMapper.getMediaType()
			).entity(
				writeError(errorMessageMapper, apiError)
			).build()
		).orElseGet(
			() -> Response.status(
				statusCode
			).build()
		);
	}

	private <E extends Throwable> void _logException(E e, String message) {
		if (_logger.isDebugEnabled()) {
			_logger.debug(message, e);
		}
		else {
			StackTraceElement stackTraceElement = e.getStackTrace()[0];

			_logger.error(
				join("\n", message, e.toString(), "at " + stackTraceElement));
		}
	}

	private static final Response _serverError = Response.serverError().build();

	@Reference
	private ErrorMessageMapperManager _errorMessageMapperManager;

	@Reference
	private ExceptionMapperManager _exceptionMapperManager;

	private final Logger _logger = getLogger(getClass());

}