
class InvalidGitlabResponseException(Exception):
    """Raised when the Gitlab HTTP response is higher or equals than 400

    Attributes
        response    -- Request Response from Gitlab
        message     -- Explanation of the error
    """

    def __init__(self, response, message="Gitlab HTTP response is higher or equals to 400."):
        self.response = response
        self.message = message
        super().__init__(self.message)
